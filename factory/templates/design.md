# Design: <title>

Run: `<run-id>` · Spec: `spec.md`

## Components

What this change touches. New parts are marked.

```mermaid
flowchart LR
  A[Existing part] --> B[New part]:::new
  B --> C[(Database)]
  classDef new stroke-width:3px,stroke-dasharray: 5 5
```

## Main flows

One sequence diagram per main flow, with its main failure path.

```mermaid
sequenceDiagram
  actor User
  participant API
  participant Service
  participant DB
  User->>API: request
  API->>Service: call
  Service->>DB: query
  DB-->>Service: rows
  Service-->>API: result
  API-->>User: 200
  alt dependency fails
    Service-->>API: error
    API-->>User: 503
  end
```

## Interface contracts

The builder implements these as written.

- **Functions / classes**: signatures
- **API routes**: method, path, request, responses and error codes
- **Events / messages**: name and shape
- **Data model**: tables, columns, indexes, migrations

## Observability plan

- **Logs**: which events, at which level, with which fields
- **Metrics**: names and labels
- **Traces**: which spans
- **Broken looks like**: the signal a person on call would see

## Risks and rollback

| Risk | Likelihood | What we do about it |
|---|---|---|
| | | |

How this is switched off or reversed:

## Decisions

ADRs written for this change:

- `docs/adr/NNNN-title.md`: one line on what was decided
