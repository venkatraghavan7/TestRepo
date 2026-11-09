# Observability standard

The test for every change: when this breaks at 3am, can the person on call tell what happened, to whom and why, from the telemetry alone?

## Logs

- **OBS-001** [review] [blocking] Logs are structured (key and value fields), not free text built by joining strings.
- **OBS-002** [review] [blocking] Every log line written while handling a request, job or message carries its correlation or request ID.
- **OBS-003** [review] [blocking] Every error path logs once, at error level, with the context needed to act: what was being done, for which entity, and the cause.
- **OBS-004** [review] [blocking] No secrets, tokens, passwords or personal data (names, emails, phone numbers, addresses, payment details) in any log line, metric label or span attribute.
- **OBS-005** [review] [advisory] Log levels mean something: error needs a human, warn is odd but handled, info marks a business event, debug is off in production.
- **OBS-006** [review] [advisory] No logging inside tight loops, and no logging of whole request or response bodies.

## Metrics

- **OBS-007** [review] [blocking] Every new entry point (endpoint, job, consumer, scheduled task) reports rate, errors and duration.
- **OBS-008** [review] [advisory] Each business event the spec cares about (order placed, quote failed) has a counter.
- **OBS-009** [review] [blocking] Metric labels have a small, fixed set of values. No user IDs, request IDs or free text as labels.
- **OBS-010** [review] [advisory] An existing metric, log field or span name is not renamed or removed without saying so in the pull request: dashboards and alerts depend on them.

## Traces

- **OBS-011** [review] [advisory] Each call to an outside system (database, HTTP, queue, cache) is inside a span, and the trace context is passed on.
- **OBS-012** [review] [advisory] Spans record the outcome: errors are set on the span, not only logged.

## Failure and operations

- **OBS-013** [review] [blocking] No exception is caught and dropped. If a failure is ignored on purpose, a comment says why and a metric counts it.
- **OBS-014** [review] [advisory] Retries are bounded, backed off and counted. The final failure is logged as an error.
- **OBS-015** [review] [advisory] Health checks still tell the truth after the change: a new hard dependency is in the readiness check.
- **OBS-016** [review] [advisory] The pull request says what would show this change is broken in production, and names any alert, dashboard or SLO it affects.
- **OBS-017** [review] [advisory] A feature behind a flag logs or tags which side of the flag served the request.
