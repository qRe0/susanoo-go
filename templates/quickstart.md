# Quickstart: [FEATURE NAME]

**Input**: `specs/[NNN-feature-name]/plan.md` and `contracts/`

Runnable validation scenarios that prove the feature works end-to-end. Reference the
contracts and data model instead of duplicating them. Do not include full implementation
code, model/service bodies, migrations, or complete test suites. Implementation detail
belongs to `tasks.md` and the implement stage.

## Prerequisites

- [e.g. Go 1.23+, Docker for local dependencies]

## Setup

```bash
# start local dependencies (PostgreSQL, Redis)
docker compose up -d

# run migrations
goose up
```

## Validation Scenarios

### [Scenario 1]

```bash
go run ./cmd/<app>        # or the project's run command
curl http://localhost:8080/[endpoint]
```

**Expected**: [the observable outcome that proves this scenario works]

### [Scenario 2]

```bash
go test -race -count=1 ./internal/[pkg]/...
```

**Expected**: [the tests that must pass]

## References

- [link to `contracts/`]
- [link to `data-model.md`]
