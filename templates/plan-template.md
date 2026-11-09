# Implementation Plan: [FEATURE]

**Branch**: `[NNN-feature-name]` | **Date**: [DATE] | **Spec**: [link to spec.md]

**Input**: Feature specification from `specs/[NNN-feature-name]/spec.md`

> **For agentic workers:** `implement` executes this plan task-by-task through `coder` /
> `test-driven-development` / `test-generator` / `code-reviewer`. Steps use `- [ ]`
> checkbox syntax for tracking.

## Summary

[Primary requirement from the spec, plus the technical approach chosen in research.]

## Technical Context

Fill every line. Mark a value as `NEEDS CLARIFICATION` when it is genuinely unknown and
must be resolved in Phase 0 research.

**Language/Version**: [e.g. Go 1.23, from go.mod]

**Primary Dependencies**: [e.g. net/http, pgx, sqlc, slog or NEEDS CLARIFICATION]

**Storage**: [e.g. PostgreSQL, Redis, files, or N/A]

**Testing**: [e.g. standard testing + testify, httptest, testcontainers-go]

**Target Platform**: [e.g. Linux server, macOS CLI, container]

**Project Type**: [e.g. HTTP service, library, CLI]

**Performance Goals**: [e.g. 1000 req/s, 10 MB/s, or NEEDS CLARIFICATION]

**Constraints**: [e.g. <200ms p95, <100MB memory, offline-capable]

**Scale/Scope**: [e.g. 10k users, 50 endpoints, or NEEDS CLARIFICATION]

## Constitution Check

*GATE: must pass before Phase 0 research. Re-check after Phase 1 design.*

- [ ] [Principle from `specs/constitution.md` satisfied, or violation justified below]

## Global Constraints

Project-wide requirements that every task inherits. Copy exact values from the spec and
constitution verbatim: version floors, dependency limits, naming rules, platform
requirements. One line each.

- [e.g. Go version >= 1.23, pinned in go.mod]
- [e.g. stdlib-first: add a dependency only with a written justification]
- [e.g. every goroutine has a stop signal and is waited on]

## Review Focus

The input classes or failure modes the spec implies but no task's tests exercise, most
likely to bite a user of this software. Name each input or condition and the behavior a
reasonable person expects. For each line, add the test that pins it to the owning task.

- [Input/condition and expected behavior]
- [Input/condition and expected behavior]

## Project Structure

### Documentation (this feature)

```text
specs/[NNN-feature]/
├── plan.md          # this file
├── research.md      # Phase 0 output
├── data-model.md    # Phase 1 output
├── quickstart.md    # Phase 1 output
├── contracts/       # Phase 1 output
└── tasks.md         # tasks stage output (not created here)
```

### Source Code (repository root)

Pick one option, delete the others, and replace the placeholders with real paths. The
delivered plan must not include option labels.

```text
# Option 1: Single service (DEFAULT)
cmd/<app>/
internal/
migrations/

# Option 2: Library (no binaries)
<module-root package> or pkg/

# Option 3: Multiple binaries / monorepo
cmd/<bin-a>/
cmd/<bin-b>/
internal/
```

**Structure Decision**: [The selected structure and the real directories it maps to.]

## Complexity Tracking

> Fill only when a Constitution Check violation must be justified.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g. repository pattern] | [specific problem] | [why direct DB access is insufficient] |

## Verification Commands

Exact commands that must pass before this plan is done. Point at `.claude/DOD.md` for the
tiered gate; list only what differs here.

- Build: `go build ./...`
- Test: `go test -race -count=1 -shuffle=on ./...`
- Vet: `go vet ./...`
- Lint: `golangci-lint run` (if configured)
- Generated code: `sqlc generate && git diff` / `buf lint` (if generated code exists)
