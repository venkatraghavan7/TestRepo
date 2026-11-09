# Standards

These files are the factory's rulebook. The builder reads them before writing code, and each reviewer checks the change against its own file.

They are starter rules. Edit them to match how you work, or run `/ingest-standards <file or URL>` to turn your own documents into rules.

## Format

```
- **OBS-003** [review] [blocking] One sentence, one requirement, checkable in a diff.
```

- **ID**: area prefix and number. Never reuse or renumber an ID: findings are logged against it.
- **`[lint]` or `[review]`**: `[lint]` rules are enforced by the linter in the gate. `[review]` rules need judgement and go to a review agent.
- **`[blocking]` or `[advisory]`**: a blocking rule stops the change until it is fixed. An advisory one is reported and left to you.

## Files

| File | Read by |
|---|---|
| `coding.md` | builder, review-architecture |
| `testing.md` | builder, review-architecture |
| `architecture.md` | designer, review-architecture |
| `security.md` | review-security |
| `observability.md` | builder, designer, review-observability |
| `ux.md` | review-ux |

## Keeping them useful

- Keep each file short enough to read in two minutes. A long rulebook is not followed.
- Move a rule to `[lint]` when a machine can check it. That is cheaper and never forgets.
- Run `/factory-learn` now and then. It reads what reviewers keep finding and proposes rules to add, sharpen or retire.
