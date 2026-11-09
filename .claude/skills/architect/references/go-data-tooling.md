# Go Data And Tooling Reference

Use this when choosing the data layer and recording verification commands in
`specs/architecture.md`.

## Data Access

| Choice | Use when | Notes |
|---|---|---|
| `database/sql` | Small SQL surface, portability | Pair with explicit queries and transactions |
| `pgx` | PostgreSQL-first services | Strong Postgres support and pool controls |
| `sqlc` | SQL-first services needing type-safe generated code | Requires query and generated-code placement rules |
| `gorm` | Existing codebase or CRUD-heavy app with team buy-in | Watch hidden queries and migration semantics |
| `ent` | Schema-first graph/domain modeling | Accept codegen and framework conventions deliberately |

Prefer explicit SQL via `database/sql`, `pgx`, or `sqlc` for service code unless the repo
already standardizes on an ORM. Generated code is regenerated from its source, never
hand-edited.

## Migrations

Common choices: `goose`, `golang-migrate`, `atlas`, `tern`, provider-managed migrations,
or existing platform tooling. Document:

- Migration directory.
- Command to create/apply/rollback.
- Transaction behavior.
- Drift check, if available.
- Local/test database strategy.

## Tooling Commands

Record the consumer repository's existing test, lint, generation, integration, and
migration runners in `specs/architecture.md`. If no runner exists, use the fallback
guidance in `.claude/DOD.md`. Do not invent build targets.
