---
name: go-data
user-invocable: false
description: Use when adding or reviewing storage, SQL, migrations, transactions, or data-access tests in Go.
metadata:
  phase: reference
  related: [coder, code-reviewer, test-generator]
---

# Go Data Access

An internal reference pulled by `coder`, `code-reviewer`, and `test-generator` when the
change touches storage, SQL, migrations, repositories/stores, or data-access tests. It does
not add a stage or change the workflow.

Read and follow `specs/architecture.md` before choosing data packages, transaction
boundaries, migration tooling, or generated-code commands.

REQUIRED SUB-SKILLS: `../go-conventions/SKILL.md`, `../test-audit/SKILL.md`. TDD is
governed by `coder` through `../test-driven-development/SKILL.md`.

## First pass

Read the profile and current data stack before choosing tools: `database/sql`, `pgx`,
`sqlc`, `gorm`, `ent`, or another established library; migration tool (goose, migrate, atlas,
embedded migrations, or manual SQL); the transaction pattern and store boundaries; and the
test strategy (unit fakes, integration database, testcontainers, or fixtures).

## Core rules

- Follow the profile's chosen data stack.
- Prefer explicit SQL (`database/sql`, `pgx`, `sqlc`) unless the repo already uses an ORM.
- Parameterized queries only.
- Keep transactions explicit and scoped to the use case.
- Avoid N+1 queries and unbounded scans.
- Review migrations as source code — especially drops, type changes, and backfills.
- Integration-test SQL and transaction behavior when unit fakes would hide the risk.

## Query design

- Name queries by business intent, not table mechanics.
- Keep filtering, sorting, and pagination explicit; use stable ordering for paginated results.
- Avoid `SELECT *` in application queries.
- Handle nullable columns deliberately (`sql.Null*`, pointers, `pgtype`, or domain helpers).
- Preserve database constraints for invariants that must survive concurrent writers.

## Transactions

- Start transactions at the use-case/service boundary that owns the invariant.
- Pass transaction handles explicitly or through a narrow store interface.
- Roll back on every error path and commit once.
- Keep external network calls outside database transactions unless a saga/outbox is required.
- Consider outbox/idempotency tables for side effects that must survive retries.

## Migrations

- Separate schema changes from risky data backfills when needed.
- Make destructive changes multi-step: add new structure, backfill, switch readers/writers,
  then remove old structure.
- Include rollback notes even when down migrations are intentionally unsupported.
- After schema/query changes, run the repo's generator (`sqlc generate`, ORM generation,
  mocks) and review the diff; treat generated code as source-of-truth-dependent output.

## Performance and reliability

- Add indexes that match new query predicates and ordering; check query plans for high-risk
  paths.
- Set statement/query timeouts through context and database settings.
- Configure connection pool limits intentionally; avoid loading unbounded result sets.

## Test checklist

- Store/repository tests cover success, not-found, constraint violation, and rollback.
- Migration tests run against a real database when possible.
- Integration tests use build tags or existing project conventions; data is isolated and
  deterministic per test.

## Common Rationalizations

- "A mock will keep the test fast." A mock that returns the asserted rows proves nothing
  about the SQL; prefer a real fake or a testcontainers/integration test at the DB boundary.
- "The ORM handles it." Even with an ORM, N+1 queries and unbounded scans still happen; check
  the query plan, not the abstraction.
- "It's a small migration, no need to review." Drops and type changes are destructive; every
  migration is source code and reviewed as such.

## Red Flags — STOP

- A hand-built SQL string with untrusted input (never use string concatenation).
- A transaction spanning an external network call without a saga/outbox.
- A destructive migration (drop/type change) with no backfill or rollback note.
- Hand-editing generated query/model output instead of regenerating from source.
