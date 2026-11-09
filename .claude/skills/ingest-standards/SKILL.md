---
name: ingest-standards
description: Turn standards documents (files, PDFs, wiki exports, URLs or the conventions in existing code) into numbered rules in factory/standards/ that the linter and the review agents enforce.
argument-hint: "<file, folder or URL> [more sources] [area: coding|security|observability|testing|architecture|ux]"
disable-model-invocation: true
---

# Ingest standards

Sources: $ARGUMENTS

If no source was given, ask what to ingest. Offer this as one option: "the conventions already in this codebase", which means reading the code, the linter config and past ADRs and writing down the rules the team already follows.

1. Start the `standards-ingester` subagent with the sources and the area, if one was given. It writes a proposal to `factory/standards/_proposed.md`. It does not change the real standards.

2. Show the user a short summary: rules proposed per area, how many are `[lint]` and how many `[review]`, then every **conflict** and every **too vague to enforce** item in full. Those need their decision.

3. **Stop and wait for approval.** The user may accept all, drop some or reword some.

4. On approval:
   - Add the accepted rules to the right `factory/standards/<area>.md` file, keeping the ID order.
   - For `[lint]` rules, make the linter config change that enforces them. Then run `.claude/hooks/gate.sh`. If existing code now fails the new rule, tell the user how many places break and ask whether to fix them now, set the rule to warn for now, or drop it. Do not leave the gate red.
   - Delete `_proposed.md`.
   - Commit with the message `standards: add <n> rules from <source>`.

5. Report which rules were added, which are enforced by lint and which by review.
