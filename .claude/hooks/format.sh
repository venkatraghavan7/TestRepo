#!/usr/bin/env bash
# Factory formatter (PostToolUse on Edit|Write). Runs commands.format on the file just changed.
# Put {file} in the command where the path should go, e.g. "npx prettier --write {file}".
# Without {file}, the path is added to the end. Never blocks.
set -u

command -v jq >/dev/null 2>&1 || exit 0
INPUT="$(cat || true)"
[ -n "$INPUT" ] || exit 0

ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
CFG="$ROOT/factory/config.json"
[ -f "$CFG" ] || exit 0

FMT="$(jq -r '.commands.format // ""' "$CFG" 2>/dev/null || echo "")"
FILE="$(jq -r '.tool_input.file_path // ""' <<<"$INPUT" 2>/dev/null || echo "")"
[ -n "$FMT" ] && [ -n "$FILE" ] && [ -f "$FILE" ] || exit 0

# Leave the factory's own files alone.
case "$FILE" in
  */factory/runs/* | */factory/logs/* | */.claude/*) exit 0 ;;
esac

QUOTED="$(printf '%q' "$FILE")"
if [[ "$FMT" == *"{file}"* ]]; then
  RUN="${FMT//\{file\}/$QUOTED}"
else
  RUN="$FMT $QUOTED"
fi

cd "$ROOT" && bash -c "$RUN" >/dev/null 2>&1
exit 0
