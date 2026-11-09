# Golden Principles - Go

Non-negotiable structural decisions for generated Go code. Architecture-specific placement lives in `specs/architecture.md`; these rules apply regardless of profile. Detailed Go style rules live in `.claude/conventions/` (`src/*.md` + `style.md`) and are consumed by the `go-conventions` sub-skill. This file is mirrored by reference from that canonical source — it states the structural decisions, never a competing style list. Document precedence is defined only in [AGENTS.md](../AGENTS.md#sources-of-truth); this file does not restate that order.
  
## Boring Go First

- Prefer the standard library until the project has a clear reason not to.
- Keep package APIs small. Export only what another package uses.
- Put interfaces at the consumer boundary, not next to every concrete implementation.
- Avoid cargo-cult enterprise layering: no default `Service`, `Manager`, `Repository` stack unless the profile or existing repo uses it.
- Do not add generic abstractions unless they remove real duplication.

## Naming and Packages

- Package names are short, lowercase, singular where natural: `user`, `billing`, `httpapi`.
- File names are lowercase with underscores only when helpful: `user_store.go`, `http_handler.go`.
- Exported names need useful comments if they are part of public package API.
- Avoid stutter: `user.Service`, not `users.UserService`.
- `cmd/<app>` is for binaries; reusable code belongs in `internal/` or package directories per the architecture profile.

## Context, Errors, and Time

- `context.Context` is the first parameter for I/O, request-scoped work, and cancellation-aware operations.
- Do not store `context.Context` in structs.
- Wrap errors with `%w`; use `errors.Is` / `errors.As` for classification.
- Do not compare error strings for control flow.
- Use UTC for persisted/comparable timestamps. Inject clock/time source when business logic depends on time.

## Concurrency

- Start goroutines only with an explicit owner, cancellation path, and error path.
- Prefer `errgroup.WithContext` for request-scoped fan-out.
- Protect shared mutable state with channels, mutexes, atomics, or ownership; do not rely on timing.
- Run the applicable race check from `.claude/DOD.md` for concurrency-heavy changes.

## HTTP and Boundaries

- Keep handlers thin: decode, validate, call application/domain code, encode response.
- Validate all external input at boundaries.
- Do not leak database rows or internal structs directly as public API responses unless the profile explicitly allows it.
- Use structured error responses consistently; do not expose stack traces or internal details.

## Data Access

- Prefer explicit SQL via `database/sql`, `pgx`, or `sqlc` for service code unless the repo already standardizes on an ORM.
- Keep transactions scoped and obvious. Pass the transaction handle through the unit of work rather than hiding it globally.
- Avoid N+1 queries, unbounded result sets, and query construction from untrusted strings.
- Migrations are source code and must be reviewed for destructive changes.

## Testing

- Use table-driven tests for behavior matrices.
- Keep tests independent and deterministic; no sleeps to mask races.
- Use `httptest` for HTTP boundaries.
- Use testcontainers or real integration fixtures for database behavior when mocks would hide SQL/transaction bugs.
- `testify` is acceptable if already used; standard `testing` is the default.

## Tooling Defaults

- `gofmt` is non-negotiable.
- Run the applicable `.claude/DOD.md` tier with the consumer repository's documented test, vet, lint, and security runners.
- Do not commit secrets, generated binaries, local `.env` files, or tool caches.
