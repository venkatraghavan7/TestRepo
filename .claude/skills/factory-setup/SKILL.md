---
name: factory-setup
description: One-time setup of the software factory in this repo - detects the stack, fills in the lint, typecheck, test and format commands, and checks the gate runs.
disable-model-invocation: true
---

# Factory setup

Set the factory up for this repository. Run once per repo, and again if the tooling changes.

1. **Check tools.** Run `jq --version`, `git --version` and `gh --version`. `jq` and `git` are required: if one is missing, tell the user how to install it and stop. `gh` is optional: without it the factory writes `PR.md` and does not open a pull request.

2. **Detect the stack.** Read the manifest and config files: `package.json` and its scripts, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`, `build.gradle`, `Makefile`, `.github/workflows/`, linter and formatter configs. Prefer the commands CI already runs: they are the ones the team trusts.

3. **Fill in `factory/config.json`:**
   - `commands.lint`, `commands.typecheck`, `commands.test`: the real commands, non-interactive, exiting non-zero on failure. No watch mode.
   - `commands.format`: a command that formats one file, with `{file}` where the path goes, for example `npx prettier --write {file}`.
   - `commands.e2e`: the end-to-end command if the project has one. Otherwise leave it empty.
   - `baseBranch`: the default branch (`git symbolic-ref refs/remotes/origin/HEAD`, or ask).
   - `tracker`: `github` if `gh` works and the user wants issues created. Otherwise `local`.
   - `observability.platform`: ask the user what they use (for example OpenTelemetry, New Relic, Datadog). Leave empty if none.
   - Leave a command empty if the project has no such tool. Tell the user which are empty and what that means: an empty `test` means the gate cannot check behaviour, and the factory will not start.

4. **If there is no linter or no test framework,** say so plainly and offer to add the standard one for the stack. Do not add it without a yes.

5. **Make the scripts executable:** `chmod +x .claude/hooks/*.sh factory/bin/*.sh`.

6. **Run the gate:** `.claude/hooks/gate.sh`. Show the result. If it fails on the code as it stands, tell the user: the factory needs a passing baseline, or every run will start by fixing old failures.

7. **Git ignore.** Make sure `.gitignore` has `factory/runs/` and `factory/logs/`. `factory/findings.jsonl` and `factory/standards/` are committed.

8. **CLAUDE.md.** If `CLAUDE.md` has no "Software factory" section, add the contents of `factory/templates/claude-md-snippet.md` to it. Create `CLAUDE.md` if there is none.

9. **Standards.** Tell the user the starter standards are in `factory/standards/` and are theirs to edit, and that `/ingest-standards <file or URL>` will turn their own documents into rules.

Finish with a short summary: the commands set, anything left empty, the gate result, and the next step (`/factory <what to build>`).
