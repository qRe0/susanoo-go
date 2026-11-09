# Architecture Profile: [PROJECT NAME]

**Module**: `[module path from go.mod]`

This is the living architecture spec (Sources-of-Truth tier 4). It is written from what is
actually in the repository, never invented. Go style rules live in `.claude/conventions/`
and are referenced here, not restated. Record rejected options so the debate does not reopen.

## Project Shape

**Style**: [standard service | vertical slice | layered | modular monolith | microservice | CLI | library]

**Module root**: [path containing go.mod]

**Go version**: [from go.mod / toolchain]

## Layout

| Package/path | Purpose | May import |
|---|---|---|
| `cmd/<app>` | composition root | internal packages |
| `internal/...` | application code | per dependency rules |
| `api/` | contracts / schemas | none, or generated code |
| `migrations/` | database migrations | N/A |

## Dependency Rules

- Allowed: [e.g. business packages import domain types; nothing imports the database driver directly]
- Forbidden: [e.g. `internal/httpapi` must not import the storage package; business packages must not import the router]
- Interface ownership: [consumer-owned | provider-owned when an existing convention requires it]

## Where Things Go

| Artifact | Location |
|---|---|
| HTTP/RPC handler | [path] |
| Request/response struct | [path] |
| Use case / service | [path] |
| Domain model | [path] |
| Persistence code | [path] |
| Migration | [path + tool] |
| Config | [path] |
| Logging / telemetry | [path] |
| Tests | [path] |

## Chosen Libraries And Tools

| Concern | Choice |
|---|---|
| Router | [net/http | chi | gin | echo | connectrpc | other] |
| Validation | [explicit | validator library] |
| Data access | [database/sql | pgx | sqlc | gorm | ent | other] |
| Migrations | [goose | atlas | golang-migrate | other | none] |
| Logging | [slog | zap | zerolog | existing] |
| Telemetry | [OpenTelemetry | none] |
| Tests | [testing | testify | other] |

## Verification Commands

**DoD**: `.claude/DOD.md`

**Test runner**: [exact existing project command, or the DoD fallback]

**Static checks**: [exact existing project commands, or the DoD fallback]

**Conditional checks**: [configured generator, lint, race, integration, migration, and contract commands]

Fill these from the repository's build files and CI. Do not invent targets.

## Testing Practice

**TDD mode**: [required | on request | not adopted - user choice, never inferred]

**Rationale**: [observed tests / CI / policy and the team decision]

**Focused test runner**: [exact command for one behavior or package, or unavailable]

`required` applies to new behavior and bug fixes. `on request` applies when the task opts
in explicitly. `not adopted` sets no default TDD obligation. All modes still follow
`.claude/DOD.md` for tests and verification. Preserve any stronger existing project policy.
