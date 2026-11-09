# Review file format

Every reviewer and the tester write one JSON file per round: `factory/runs/<run-id>/reviews/r<round>-<name>.json`.

It must be valid JSON and nothing else: no Markdown fence, no text before or after.

```json
{
  "reviewer": "observability",
  "run": "20261110-export-csv",
  "round": 1,
  "verdict": "CHANGES",
  "summary": "One error path is invisible. Otherwise sound.",
  "findings": [
    {
      "rule": "OBS-003",
      "severity": "blocking",
      "file": "src/export/handler.ts",
      "line": 42,
      "problem": "The catch block returns 500 but logs nothing, so a failed export leaves no trace.",
      "fix": "Log at error level with requestId, userId and the cause before returning."
    }
  ]
}
```

## Fields

- `reviewer`: `security`, `observability`, `architecture`, `ux` or `tester`.
- `verdict`: `PASS` when there are no blocking findings. `CHANGES` when there is at least one.
- `findings`: an empty list is fine and common.
- `rule`: a rule ID from `factory/standards/` (`SEC-004`), an acceptance criterion (`AC-02`), an ADR (`ADR-0007`), `SPEC-GAP` when the spec is silent on something that matters, or `NONE` when nothing covers it. `NONE` tells the factory a standard is missing.
- `severity`: `blocking` must be fixed before approval. `advisory` is reported and left to the human.
- `file`, `line`: where it is. Use `""` and `0` only when a finding is about something missing altogether.
- `problem`: what is wrong and what it leads to, in one or two sentences.
- `fix`: the concrete change to make.

Each finding is copied to `factory/findings.jsonl` by `factory/bin/collect-findings.sh`. That log is what `/factory-learn` reads.
