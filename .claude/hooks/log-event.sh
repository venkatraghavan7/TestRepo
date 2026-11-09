#!/usr/bin/env bash
# Factory event log (SubagentStop). One line per finished subagent in factory/logs/events.jsonl,
# so you can see which stations ran, in what order and how often. Never blocks.
set -u

command -v jq >/dev/null 2>&1 || exit 0
INPUT="$(cat || true)"
[ -n "$INPUT" ] || exit 0

ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
[ -d "$ROOT/factory" ] || exit 0
mkdir -p "$ROOT/factory/logs" 2>/dev/null || exit 0

jq -c --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '{ts:$ts, event:(.hook_event_name // ""), agent:(.agent_type // ""), agent_id:(.agent_id // ""), session:(.session_id // "")}' \
  <<<"$INPUT" >>"$ROOT/factory/logs/events.jsonl" 2>/dev/null || true
exit 0
