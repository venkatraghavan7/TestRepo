# Testing standard

- **TST-001** [review] [blocking] Every acceptance criterion in the spec has at least one test that would fail if the criterion were not met.
- **TST-002** [review] [blocking] Tests are written before the code they cover: red, then green, then refactor.
- **TST-003** [review] [advisory] Tests check behaviour through public interfaces, not internals. A refactor that keeps behaviour should not break them.
- **TST-004** [review] [blocking] No test is weakened, skipped or deleted to make a change pass. A wrong test is fixed, and the pull request says why.
- **TST-005** [review] [advisory] Each test checks one behaviour, and its name says which, so a failure reads as a sentence.
- **TST-006** [review] [advisory] Tests cover the unhappy paths: bad input, missing data, a dependency failing, no permission.
- **TST-007** [review] [blocking] Tests do not depend on each other, on run order, on the clock or on the network. Time and outside services are faked at the boundary.
- **TST-008** [review] [advisory] Mock only what you do not own: outside services, time, randomness. Do not mock the code under test or its close collaborators.
- **TST-009** [review] [blocking] A bug fix starts with a test that reproduces the bug.
- **TST-010** [review] [advisory] User-facing flows named in the spec have an end-to-end test where the project has an e2e framework.
- **TST-011** [review] [advisory] Test data is built in the test or a named factory, so a reader can see what matters without opening a fixture file.
