#!/usr/bin/env bash
# Factory gate: runs the lint / typecheck / test commands from factory/config.json.
#
#   gate.sh                    by hand or from the orchestrator. Exit 0 = pass, 1 = fail.
#   gate.sh --hook             Stop hook for the main session. Exit 2 stops Claude from finishing.
#   gate.sh --hook --builder   Stop hook for the builder subagent. Always runs.
#
# It stops at the first failing step so feedback is fast.
set -u

HOOK=0
BUILDER=0
for a in "$@"; do
  case "$a" in
    --hook) HOOK=1 ;;
    --builder) BUILDER=1 ;;
  esac
done

INPUT='{}'
if [ "$HOOK" = 1 ]; then
  INPUT="$(cat || true)"
  [ -n "$INPUT" ] || INPUT='{}'
fi

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
CFG="$ROOT/factory/config.json"
LOGDIR="$ROOT/factory/logs"

# A hook must never break a session because the kit is half installed.
if ! command -v jq >/dev/null 2>&1; then
  [ "$HOOK" = 1 ] && exit 0
  echo "gate: jq is not installed. Install jq, then run again."
  exit 1
fi
if [ ! -f "$CFG" ]; then
  [ "$HOOK" = 1 ] && exit 0
  echo "gate: factory/config.json not found."
  exit 1
fi

cd "$ROOT" || exit 0

SESSION="$(jq -r '.session_id // "manual"' <<<"$INPUT" 2>/dev/null || echo manual)"
AGENT="$(jq -r '.agent_type // ""' <<<"$INPUT" 2>/dev/null || echo "")"

# Main session: only enforce when switched on and when there is uncommitted work.
if [ "$HOOK" = 1 ] && [ "$BUILDER" = 0 ]; then
  [ "$(jq -r '.gate.enforceOnMainSession' "$CFG")" = "false" ] && exit 0
  [ -z "$(git status --porcelain 2>/dev/null)" ] && exit 0
fi

TMP="${TMPDIR:-/tmp}"
KEY="$(printf '%s' "$ROOT" | cksum | cut -d' ' -f1)"
FP_FILE="$TMP/factory-gate-$KEY.pass"
CNT_FILE="$TMP/factory-gate-$KEY-$SESSION.count"

# Fingerprint of the code as it stands. If it already passed, don't run again.
fingerprint() {
  {
    git rev-parse HEAD 2>/dev/null
    git status --porcelain 2>/dev/null
    git diff HEAD 2>/dev/null
    git ls-files -o --exclude-standard -z 2>/dev/null | xargs -0 cksum 2>/dev/null
  } | cksum | cut -d' ' -f1
}
FP="$(fingerprint)"
if [ "$HOOK" = 1 ] && [ -f "$FP_FILE" ] && [ "$(cat "$FP_FILE")" = "$FP" ]; then
  exit 0
fi

STEPS="$(jq -r '(.gate.steps // ["lint","typecheck","test"])[]' "$CFG")"
STEP_TIMEOUT="$(jq -r '.gate.stepTimeoutSeconds // 600' "$CFG")"
MAX="$(jq -r '.gate.maxAttempts // 5' "$CFG")"

ran=0
failed=""
report=""
for step in $STEPS; do
  cmd="$(jq -r --arg s "$step" '.commands[$s] // ""' "$CFG")"
  [ -z "$cmd" ] && continue
  ran=$((ran + 1))
  out="$(mktemp)"
  if command -v timeout >/dev/null 2>&1; then
    timeout "$STEP_TIMEOUT" bash -c "$cmd" >"$out" 2>&1
  else
    bash -c "$cmd" >"$out" 2>&1
  fi
  code=$?
  if [ "$code" -ne 0 ]; then
    failed="$step"
    report="$(tail -n 60 "$out")"
    rm -f "$out"
    break
  fi
  rm -f "$out"
done

log() {
  mkdir -p "$LOGDIR" 2>/dev/null || return 0
  jq -nc --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg result "$1" --arg step "$failed" \
    --arg agent "$AGENT" --arg session "$SESSION" --argjson ran "$ran" \
    '{ts:$ts, result:$result, failed_step:$step, steps_run:$ran, agent:$agent, session:$session}' \
    >>"$LOGDIR/gate.jsonl" 2>/dev/null || true
}

if [ "$ran" -eq 0 ]; then
  [ "$HOOK" = 1 ] && exit 0
  echo "gate: no commands set in factory/config.json. Run /factory-setup."
  exit 1
fi

if [ -z "$failed" ]; then
  # Formatters may have changed files during the run, so take the fingerprint again.
  fingerprint >"$FP_FILE" 2>/dev/null || true
  rm -f "$CNT_FILE"
  log pass
  [ "$HOOK" = 1 ] || echo "gate: PASS ($ran steps)"
  exit 0
fi

log fail

if [ "$HOOK" = 0 ]; then
  echo "gate: FAIL at '$failed'"
  echo "$report"
  exit 1
fi

count=0
[ -f "$CNT_FILE" ] && count="$(cat "$CNT_FILE" 2>/dev/null || echo 0)"
count=$((count + 1))

if [ "$count" -gt "$MAX" ]; then
  rm -f "$CNT_FILE"
  echo "Factory gate: '$failed' still fails after $MAX attempts. Stopping so a human can look." >&2
  exit 1
fi

echo "$count" >"$CNT_FILE"
{
  echo "Factory gate FAILED at '$failed' (attempt $count of $MAX). You cannot finish until it passes."
  echo "Fix the cause. Do not weaken, skip or delete tests or lint rules to get past it."
  echo "--- last lines of output ---"
  echo "$report"
} >&2
exit 2
