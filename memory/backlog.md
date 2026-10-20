# Backlog

Pending work and adopted target constraints. Current progress and verification belong in [current.md](current.md). Completed work should leave this list once any durable conclusions have been incorporated into current knowledge; Git history preserves its evolution.

- Refactor `tests/` dependency injection. After this refactor, direct dependencies through parent-relative paths such as `../*` or `../../*` are prohibited throughout tests, including imports and repository-root path references. Dependencies outside a test's directory must be supplied through function parameters rather than obtained by traversing parent directories. This is an owner-adopted target constraint for the future refactor, not a claim that current tests already comply. No test-code change is authorized by this backlog entry alone.
