# Security standard

- **SEC-001** [review] [blocking] No secrets, keys, tokens or passwords in code, tests, config files, logs or commit history.
- **SEC-002** [review] [blocking] Every new endpoint or action checks who the caller is and whether they are allowed, on the server.
- **SEC-003** [review] [blocking] A caller can reach only their own data: object IDs from the request are checked against the caller's rights.
- **SEC-004** [review] [blocking] Queries use parameters or the ORM. No SQL, shell command, HTML or file path is built by joining strings with user input.
- **SEC-005** [review] [blocking] All outside input is validated for type, length, range and format before use, and rejected if it fails.
- **SEC-006** [review] [blocking] Output shown in a browser is escaped for its context. No raw HTML from user input.
- **SEC-007** [review] [blocking] Personal data is collected only when the spec needs it, never logged, and encrypted in transit.
- **SEC-008** [review] [blocking] Error responses do not reveal stack traces, queries, internal paths or whether an account exists.
- **SEC-009** [review] [blocking] A new dependency is actively maintained and has no known high-severity vulnerability.
- **SEC-010** [review] [advisory] Endpoints that can be abused (login, signup, search, export, anything sending email or SMS) have rate limits.
- **SEC-011** [review] [blocking] File uploads are checked for type and size, stored outside the web root and never executed.
- **SEC-012** [review] [blocking] State-changing requests are protected against cross-site request forgery where sessions use cookies.
- **SEC-013** [review] [advisory] Security-relevant events (login, failed login, permission change, data export) are written to an audit log.
- **SEC-014** [review] [blocking] Requests the server makes to URLs supplied by a user are restricted to an allowlist.
