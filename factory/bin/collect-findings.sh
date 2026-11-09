#!/usr/bin/env bash
# Copies the findings from one review round into factory/findings.jsonl (the learning log).
#   collect-findings.sh <run-id> <round>
set -eu

RUN="${1:?usage: collect-findings.sh <run-id> <round>}"
ROUND="${2:?usage: collect-findings.sh <run-id> <round>}"
ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
DIR="$ROOT/factory/runs/$RUN/reviews"
OUT="$ROOT/factory/findings.jsonl"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

count=0
for f in "$DIR"/r"$ROUND"-*.json; do
  [ -f "$f" ] || continue
  if ! jq -e . "$f" >/dev/null 2>&1; then
    echo "skipped (not valid JSON): $f" >&2
    continue
  fi
  n="$(jq '(.findings // []) | length' "$f")"
  jq -c --arg ts "$TS" --arg run "$RUN" --argjson round "$ROUND" \
    '. as $r | ($r.findings // [])[] | . + {ts:$ts, run:$run, round:$round, reviewer:($r.reviewer // "unknown")}' \
    "$f" >>"$OUT"
  count=$((count + n))
done
echo "collected $count findings from round $ROUND of $RUN"
