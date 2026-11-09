---
name: init
description: Use when adopting Susanoo into a Go repository for the first time, or revisiting onboarding after the project setup changes: profile go.mod/go.work/tooling, establish a green baseline, and record the operating mode and TDD choice.
metadata:
  phase: onboarding
  flow-next: constitution
  related: [constitution, architect]
---

# Init

Run once per repository. `init` profiles what is already there, wires the kit in without
imposing a layout the repo does not have, and records the two decisions every later stage
reads. It does not write specs, code, or rules beyond what the steps below say.

## Step 1 — Detect

Inspect before touching:

- `go version`, `go env GOMOD GOWORK GOTOOLCHAIN`
- `go list ./...` if a module exists
- `go.mod`, `go.work`, `Makefile`, `Taskfile.yml`, `.golangci.yml`, `Dockerfile`, `migrations/`
- package layout: `cmd/`, `internal/`, `pkg/`, `api/`, feature packages, generated code
- existing AI infra: `CLAUDE.md`, `AGENTS.md`, `.claude/skills/`, `.claude/hooks/`, `specs/`, `tasks/`
- test evidence: `*_test.go` files, focused test commands, CI checks, any documented TDD policy
- whether `.claude/client/acceptance-criteria.md` is absent, empty, or already holds team rules

Do not read `.env`, `secrets/`, or external agreement documents without explicit
authorization. Summarize module name, Go version, package count, tooling, migrations, and
existing AI infra. Do not invent a project purpose from a repository name.

## Step 2 — Establish a green baseline

Run `go build ./...` and the repository's documented test runner (or the DoD fallback)
before any change. A red baseline is recorded as-is; `init` does not fix it.

## Step 3 — Record the operating mode

Ask which mode the project uses, or detect it from the layout:

1. **In-repo inject** — Susanoo lives inside the target repo; artifacts stay in `specs/`
   and `tasks/` at the repo root.
2. **Root-folder** — Susanoo lives in its own folder and drives repos under `projects/`;
   artifacts live under `.susanoo/<project>/`.

Record the choice in the `.susanoo/` state area — a single line (`in-repo` or `root-folder`)
in `.susanoo/mode`, alongside the existing `.susanoo/feature` pointer. Only the artifact
root moves; every stage, rule, and gate is identical in both modes.

## Step 4 — Record the TDD choice

Read `specs/architecture.md` if present and it already states a TDD practice; report and
follow that. Otherwise recommend one from the test evidence and ask — do not infer consent:

- **required** — focused tests run reliably and the team wants test-first discipline.
- **on request** — tests run but no test-first convention is established; the usual
  recommendation for an existing tested project.
- **not adopted** — no TDD workflow; `.claude/DOD.md` test gates still apply.

Record the choice in `.susanoo/tdd` (a single line: `required`, `on-request`,
`not-adopted`, or `unresolved`). The durable persistence into `specs/architecture.md`
happens in `architect`, which reads this value (or the Context Summary) and never silently
overrides a user's choice.

## Step 5 — Project rules file

Ensure `.claude/client/acceptance-criteria.md` exists. If missing, create the directory and
a zero-byte file; if present, preserve its bytes exactly. Do not seed a sample rule, add
metadata, or create a second client document. Tell the user the file is empty by default
and they add hard rules themselves. The file is project-owned; agents do not populate or
revise it unless asked.

## Step 6 — Scaffold hygiene (offer, do not force)

Offer, and create only after confirmation: `.golangci.yml` (linting), `.editorconfig`
(newline/indent basics), `Makefile`/`Taskfile.yml` (only if the repo already wraps
commands), `tools.go` (only if the repo uses that pattern). Do not run `go mod init` unless
the user confirms the module path.

## Verify setup

Run the applicable Minimum tier in `.claude/DOD.md` and record the repository's available
test and lint runners with exact commands and results.

## Common Rationalizations

- "I can infer the mode from the layout." Inferring mode is a guess; a wrong mode puts
  every later artifact in the wrong root. Ask when the layout is ambiguous.
- "No one said TDD, so it's not adopted." Absence of a decision is `unresolved`, not
  `not adopted`; record it and let `architect` ask again with more evidence.
- "I'll just create a starter `.golangci.yml`." Scaffold is opt-in; an unrequested config
  file is the opposite of enhance-never-overwrite.

## Red Flags — STOP

- Editing `.claude/client/acceptance-criteria.md` (it is project-owned).
- Reading `.env`, `secrets/`, or external agreements without authorization.
- Running `go mod init` or installing tooling without confirmation.
- Advancing to the next stage automatically (execute `init`, then STOP).
