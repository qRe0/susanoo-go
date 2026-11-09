# Preset: Standard Service

One deployable HTTP service with a thin transport layer, application use cases, and an
explicit store boundary. The default when no stronger signal points at another shape.

```text
cmd/<service>/main.go
internal/transport/http/     # handlers, middleware, DTO mapping
internal/app/                # use cases, orchestration
internal/store/              # persistence, behind a consumer-owned interface
internal/platform/           # config, logging, telemetry
api/                         # generated contracts, if any
migrations/                  # if the repo uses migrations
```

## Default placement

| Artifact | Location |
|---|---|
| HTTP handler | `internal/transport/http/` |
| Request/response struct | `internal/transport/http/` |
| Use case / service | `internal/app/` |
| Domain model | `internal/app/` (or a domain package when boundaries demand it) |
| Persistence code | `internal/store/` |
| Migration | `migrations/` |
| Config | `internal/platform/config/` |
| Logging / telemetry | `internal/platform/` |
| Tests | alongside each package |

## Default tool choices

| Concern | Choice |
|---|---|
| Router | `net/http` (upgrade to `chi` only if route grouping/middleware require it) |
| Validation | explicit |
| Data access | `pgx` or `sqlc` (or `database/sql` when the SQL surface is small) |
| Migrations | repo's existing tool, or none if no schema |
| Logging | `log/slog` |
| Telemetry | none unless the repo already runs it |
| Tests | standard `testing` (+ `testify` only if already established) |

## Dependency rules

- `internal/transport/http` may import `internal/app` and `internal/platform`.
- `internal/app` may import `internal/store` (behind an interface it owns) and domain types.
- `internal/store` imports the database driver only.
- No package imports `internal/transport` (handlers are leaves).
- Framework and database types stay out of `internal/app`.
