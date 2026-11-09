# Architecture standard

- **ARC-001** [review] [blocking] The change complies with the accepted ADRs in `docs/adr/`. Departing from one needs a new ADR that replaces it.
- **ARC-002** [review] [blocking] Dependencies point one way: domain logic does not import from delivery (HTTP, UI, CLI) or infrastructure (database, queues, vendors).
- **ARC-003** [review] [advisory] Business rules live in one place. They are not repeated across handlers, views and jobs.
- **ARC-004** [review] [blocking] A change to a public interface (API, event, shared library, database schema) keeps existing callers working, or the break is called out in the spec and the pull request.
- **ARC-005** [review] [blocking] Database changes ship as migrations that can run while the old code is still live, and each has a way back.
- **ARC-006** [review] [advisory] Outside services are reached through one adapter each, so the vendor can be swapped or faked.
- **ARC-007** [review] [blocking] Every call to an outside service has a timeout, and the code says what happens when it fails.
- **ARC-008** [review] [advisory] Risky changes go behind a flag so that deploying and releasing are separate steps.
- **ARC-009** [review] [advisory] A real design decision (one a reasonable engineer could have made differently) is recorded as an ADR.
- **ARC-010** [review] [advisory] The change does not add shared mutable state or a hidden coupling between modules.
- **ARC-011** [review] [blocking] Work that can be retried or delivered twice (jobs, consumers, webhooks) is safe to run twice.
