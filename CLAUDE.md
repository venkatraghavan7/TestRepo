# TestRepo

## Software factory

This repo is set up for the software factory, which is installed globally in `~/.claude/`. This repo holds only its own settings in `factory/config.json`.

- Build features with `/factory <what to build>`. Lanes: `quick` for small fixes, `standard` for features, `full` for risky or cross-cutting work.
- The factory's standards (in `~/.claude/factory/standards/`) apply to all code here, whether or not the factory wrote it. Read the relevant file before changing code.
- Work test-first: a failing test, then the least code to pass it, then tidy.
- A gate hook runs the commands in `factory/config.json` (lint, typecheck, tests) when you try to finish. If it fails, fix the cause. Never weaken, skip or delete a test or lint rule to pass it.
- Never read `.env` files, never push to the base branch, never merge a pull request. A human merges.
- Domain words are defined in `CONTEXT.md`. Use them, and add new ones there.
- Decisions are recorded in `docs/adr/`. Follow them, or write a new ADR that replaces one.
