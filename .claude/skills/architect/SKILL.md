---
name: architect
description: Use when establishing or updating the living architecture profile at specs/architecture.md: package placement, dependency rules, data/transport conventions, verification commands, and the TDD choice.
metadata:
  phase: planning
  flow-next: specify
  flow-alternatives: [api]
  related: [init, api, coder, code-reviewer]
---

# Architect

Owns the per-project architecture profile `specs/architecture.md`. Every downstream stage
(`specify` → `implement` → `review` → `verify`) conforms to it. The profile is written from
what the repository actually contains, never invented.

REQUIRED SUB-SKILL: `../ponytail/SKILL.md` — apply its smallest-sufficient-solution ladder
when choosing the profile.

## Required reads

- `../ponytail/SKILL.md`
- `templates/architecture.md` — the output shape.
- `references/go-layouts.md`, `references/go-transports.md`, `references/go-data-tooling.md`,
  and `presets/` — decision guidance.
- `specs/README.md`, `specs/MANIFEST.md`, and `specs/architecture.md` if present.
- `AGENTS.md` and `.claude/GOLDEN-PRINCIPLES.md` — the rules the profile points at, not
  restates.

## Detect first

Inspect: `go.mod` module path and Go version; `go.work`; `go list ./...` package graph;
directories `cmd/`, `internal/`, `pkg/`, `api/`, `migrations/`; framework/tool signals
(`net/http`, `chi`, `gin`, `echo`, `grpc`, `connectrpc`, `sqlc`, `gorm`, `ent`, `pgx`,
`goose`, `atlas`, `cobra`, `wire`, `fx`); test style; CI checks; any TDD choice recorded at
`init`. Record the module path from `go.mod`. If `go.mod` is absent, record the missing
decision in `specs/MANIFEST.md` and route to `init` — never invent a module path.

## Choose the profile

Pick the lightest profile that protects real boundaries. Do not choose hexagonal or a
modular monolith because the project might grow; upgrade only when current requirements
prove the boundary is needed. Record rejected options briefly so the debate does not
reopen without new evidence.

| Profile | When it fits |
|---|---|
| Standard service | One deployable, `cmd/` + `internal/`, clear infra packages |
| Package-by-feature | Features own handler/service/store/tests together |
| Hexagonal | Domain-heavy code with explicit ports/adapters |
| Modular monolith | One deployable, bounded modules, future split possible |
| Microservices | Multiple independently deployable services |
| CLI/tool | flag/cobra command app |

## Write `specs/architecture.md`

Fill `templates/architecture.md` with: module name and Go version; profile and rationale;
package layout table; allowed/forbidden dependencies; where handlers, domain logic,
storage, migrations, config, tests, and generated code go; selected router/RPC, data
access, migration, logging, and telemetry tools; verification commands (from the repo's
build files and CI, not invented); and the TDD practice.

**TDD practice**: preserve an existing policy. Otherwise read the choice recorded at
`init` (`.susanoo/tdd`, or the Context Summary); if it is `unresolved`, recommend one from
the observed test setup and ask — do not silently select it. Record `required`, `on request`, or `not adopted` plus its rationale
and the exact focused test runner (if available). A missing decision does not impose TDD,
but does not waive `.claude/DOD.md` test gates.

## Update procedure

1. Read `specs/README.md`, `specs/MANIFEST.md`, and the current `specs/architecture.md`.
2. Create from the template when missing; otherwise update the affected sections in place —
   never keep a competing copy.
3. Record each material change under `### [{task-name}] <Decision> (YYYY-MM-DD)`.
4. Keep task-specific analysis and rejected alternatives in an optional
   `tasks/<task-dir>/architect-notes.md`; never duplicate the profile there.
5. Put unresolved cross-task decisions in `specs/MANIFEST.md` Open Decisions, not as
   established architecture.
6. Index `specs/architecture.md` in `specs/MANIFEST.md`; update the index date only when a
   decision materially changes.

## Go architecture rules

- Prefer fewer packages until boundaries are real.
- Avoid import cycles by moving shared contracts downward or narrowing interfaces at
  consumers.
- Do not use `pkg/` as a dumping ground; `internal/` holds app-private code.
- Framework and generated types do not leak into domain packages.
- Database transaction boundaries are explicit.

Then STOP with Context Summary + Next Steps.

## Common Rationalizations

- "A modular monolith future-proofs the split." A split that may never happen is
  speculative structure; the lightest profile that protects real boundaries wins.
- "I'll pick the framework I know." The profile records what the repo already uses; a
  greenfield choice still needs a one-line rationale, not a habit.
- "I can reuse a preset without checking the repo." A preset is a shortcut, not authority;
  every line is corrected against the actual repo.

## Red Flags — STOP

- Inventing a module path when `go.mod` is absent.
- Picking hexagonal or a microservice split without a proven boundary.
- Silently recording a TDD practice the user did not choose.
- Restating Go-style rules in the profile instead of pointing at `.claude/conventions/`.
