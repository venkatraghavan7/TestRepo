---
name: factory-learn
description: Review what the factory's reviewers keep finding and propose changes to the standards, lint rules and agent prompts so the same problems stop recurring.
disable-model-invocation: true
---

# Factory learning loop

Each review finding is logged to `factory/findings.jsonl`. This command turns repeated findings into prevention.

1. Run `factory/bin/stats.sh` and read `factory/findings.jsonl`. If there are fewer than about 10 findings, say there is not enough to learn from yet and stop.

2. Look for these patterns:
   - **The same rule broken across several runs.** The builder is not absorbing it. Can it become a `[lint]` rule so the gate catches it before review? If not, should it be stated more sharply, or added to the builder's prompt or `CLAUDE.md`?
   - **Findings with rule `NONE` that repeat.** A standard is missing. Draft the rule.
   - **`SPEC-GAP` findings that repeat.** The spec template or the grill questions are missing something. Propose the addition.
   - **A rule that only ever yields advisory findings nobody fixes.** It is noise. Propose retiring or rewording it.
   - **A reviewer that never finds anything, or finds what another already found.** Propose narrowing or dropping it for some lanes.
   - **Gate failures clustered at one step** (see `factory/logs/gate.jsonl`). Something upstream could prevent them.

3. Propose **at most five changes**, most valuable first. For each: the evidence (how many findings, across how many runs), the exact change (the new rule text, the lint config, the prompt edit) and what it should prevent.

4. **Stop and wait for approval.** Apply only what the user accepts. For new lint rules, run `.claude/hooks/gate.sh` afterwards and handle failures in existing code as `/ingest-standards` does.

5. Commit with the message `factory: learn from <n> findings`, with the changes listed in the body.

Keep the standards short. A new rule should earn its place: prefer sharpening or automating an existing rule over adding another.
