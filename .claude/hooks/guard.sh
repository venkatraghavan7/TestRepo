#!/usr/bin/env bash
# Factory guard (PreToolUse). Exit 2 blocks the tool call and shows the reason to Claude.
#
#   guard.sh             rules for every session
#   guard.sh --builder   extra rules for the builder subagent
#
# Rules:
#   1. Nobody reads or writes secret files (.env, private keys).
#   2. No force-push, no push to the base branch, no merging PRs, no --no-verify.
#   3. The builder never sees the hidden test scenarios (any path containing "holdout").
#   4. The builder cannot edit the gate, the guard, the config or the standards.
set -u

command -v jq >/dev/null 2>&1 || exit 0

INPUT="$(cat || true)"
[ -n "$INPUT" ] || exit 0

MODE="${1:-}"
AGENT="$(jq -r '.agent_type // ""' <<<"$INPUT" 2>/dev/null || echo "")"
TOOL="$(jq -r '.tool_name // ""' <<<"$INPUT" 2>/dev/null || echo "")"
CMD="$(jq -r '.tool_input.command // ""' <<<"$INPUT" 2>/dev/null || echo "")"
CWD="$(jq -r '.cwd // ""' <<<"$INPUT" 2>/dev/null || echo "")"
PATHS="$(jq -r '[.tool_input.file_path, .tool_input.path, .tool_input.pattern, .tool_input.glob]
                | map(select(. != null and . != "")) | join("\n")' <<<"$INPUT" 2>/dev/null || echo "")"
FILE="$(jq -r '.tool_input.file_path // ""' <<<"$INPUT" 2>/dev/null || echo "")"

ROOT="${CLAUDE_PROJECT_DIR:-$CWD}"
BASE="main"
if [ -f "$ROOT/factory/config.json" ]; then
  BASE="$(jq -r '.baseBranch // "main"' "$ROOT/factory/config.json" 2>/dev/null || echo main)"
fi

deny() {
  echo "Factory guard blocked this: $1" >&2
  exit 2
}

IS_BUILDER=0
if [ "$MODE" = "--builder" ] || [ "$AGENT" = "builder" ]; then
  IS_BUILDER=1
fi

# 1. Secrets ---------------------------------------------------------------
SAFE_ENV='\.env\.(example|sample|template|dist)$'
while IFS= read -r p; do
  [ -z "$p" ] && continue
  if grep -Eq '(^|/)\.env(\.[A-Za-z0-9_.-]+)?$' <<<"$p" && ! grep -Eq "$SAFE_ENV" <<<"$p"; then
    deny "secret file ($p). Use .env.example for the shape, never the real values."
  fi
  if grep -Eq '(\.pem|\.p12|\.pfx|(^|/)id_(rsa|ed25519|ecdsa))$' <<<"$p"; then
    deny "private key file ($p)."
  fi
done <<<"$PATHS"

if [ "$TOOL" = "Bash" ] && [ -n "$CMD" ]; then
  # A .env file named in a shell command, but not .env.example and the like.
  hits="$(grep -Eo "(^|[[:space:]/'\"=<])\.env(\.[A-Za-z0-9_-]+)?([[:space:]'\";|&)>]|$)" <<<"$CMD" || true)"
  if [ -n "$hits" ] && [ -n "$(grep -Ev '\.env\.(example|sample|template|dist)' <<<"$hits" || true)" ]; then
    deny "the command touches a .env file."
  fi

  # 2. Git safety ----------------------------------------------------------
  if grep -Eq '(^|[;&|[:space:]])git[[:space:]]+push' <<<"$CMD"; then
    if grep -Eq '[[:space:]](--force|-f)([[:space:]]|$)' <<<"$CMD"; then
      deny "force-push. Use --force-with-lease on your own feature branch if you must."
    fi
    if grep -Eq "[[:space:]:](main|master|$BASE)([[:space:]]|$)" <<<"$CMD"; then
      deny "push to the base branch. Work goes through a pull request that a human merges."
    fi
    branch="$(git -C "${CWD:-.}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")"
    if [ "$branch" = "main" ] || [ "$branch" = "master" ] || [ "$branch" = "$BASE" ]; then
      deny "push while on '$branch'. Create a feature branch first."
    fi
  fi
  if grep -Eq '(^|[;&|[:space:]])gh[[:space:]]+pr[[:space:]]+merge' <<<"$CMD"; then
    deny "merging a pull request. A human merges."
  fi
  if grep -Eq '(^|[;&|[:space:]])git[[:space:]].*--no-verify' <<<"$CMD"; then
    deny "--no-verify skips checks. Fix the failing check."
  fi
fi

# 3 and 4. Builder-only rules ------------------------------------------------
if [ "$IS_BUILDER" = 1 ]; then
  if grep -qi 'holdout' <<<"$PATHS" || grep -qi 'holdout' <<<"$CMD"; then
    deny "the holdout scenarios are hidden from the builder. Build from the spec and the ticket."
  fi
  if [ "$TOOL" = "Edit" ] || [ "$TOOL" = "Write" ]; then
    if grep -Eq '(^|/)(\.claude/(hooks|agents|skills)/|\.claude/settings(\.local)?\.json$|factory/(config\.json$|standards/|bin/))' <<<"$FILE"; then
      deny "the builder cannot change the factory's own gates, config or standards ($FILE)."
    fi
  fi
  if [ "$TOOL" = "Bash" ] && grep -Eq '(>|tee|sed[[:space:]]+-i|rm|mv|cp)[^;&|]*(\.claude/(hooks|settings)|factory/(config\.json|standards))' <<<"$CMD"; then
    deny "the builder cannot change the factory's own gates, config or standards."
  fi
fi

exit 0
