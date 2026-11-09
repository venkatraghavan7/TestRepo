# Coding standard

- **COD-001** [review] [blocking] The change does what the ticket asks and nothing else: no unrequested features, options or refactors.
- **COD-002** [review] [advisory] New code follows the patterns already used in this codebase for the same job, and does not bring in a second way.
- **COD-003** [review] [advisory] Names say what a thing is or does in the domain's words, as used in `CONTEXT.md`. No abbreviations a new reader would have to look up.
- **COD-004** [review] [advisory] A function does one thing. If you need "and" to describe it, split it.
- **COD-005** [review] [blocking] Errors are handled where something useful can be done, and otherwise passed up. No empty catch blocks and no errors swallowed in silence.
- **COD-006** [review] [blocking] Input is validated where it enters the system: requests, files, queue messages, environment variables. Inner code can then trust it.
- **COD-007** [review] [advisory] No dead code, commented-out code or leftover debug output in the diff.
- **COD-008** [review] [advisory] Comments explain why, not what. Code that needs a "what" comment should be made clearer.
- **COD-009** [review] [blocking] No new dependency without a stated reason in the pull request. Prefer the standard library and what is already installed.
- **COD-010** [review] [advisory] Configuration comes from config or the environment, not from values written into the code.
- **COD-011** [lint] [blocking] The code passes the project's linter, formatter and type checker with no new suppressions. A suppression needs a comment saying why.
- **COD-012** [review] [advisory] Simple beats clever. No abstraction is added until there are at least two real uses for it.
