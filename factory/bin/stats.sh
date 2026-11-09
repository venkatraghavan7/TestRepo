#!/usr/bin/env bash
# Factory stats: which rules get broken most, which reviewers find most, how the gate is doing.
set -eu

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
F="$ROOT/factory/findings.jsonl"
G="$ROOT/factory/logs/gate.jsonl"

if [ -s "$F" ]; then
  echo "== Findings by rule (most broken first) =="
  jq -rs 'group_by(.rule) | map({rule:(.[0].rule // "none"), total:length,
            blocking:(map(select(.severity=="blocking")) | length), runs:(map(.run) | unique | length)})
          | sort_by(-.total) | .[] | "\(.total)\t\(.blocking) blocking\t\(.runs) runs\t\(.rule)"' "$F"
  echo
  echo "== Findings by reviewer =="
  jq -rs 'group_by(.reviewer) | map("\(length)\t\(.[0].reviewer)") | .[]' "$F"
  echo
  echo "== Findings with no rule (candidates for a new standard) =="
  jq -rs 'map(select((.rule // "") == "" or .rule == "NONE")) | length' "$F"
else
  echo "No findings logged yet."
fi

if [ -s "$G" ]; then
  echo
  echo "== Gate =="
  jq -rs '"runs: \(length)   pass: \(map(select(.result=="pass")) | length)   fail: \(map(select(.result=="fail")) | length)"' "$G"
  jq -rs 'map(select(.result=="fail")) | group_by(.failed_step) | map("\(length) failures at \(.[0].failed_step)") | .[]' "$G"
fi
