---
name: docs
description: Use when the developer asks for documentation — README, ADRs, changelog, runbook, package/API docs generated from specs/ and source, hard-gated by writing-quality.
metadata:
  phase: finalization
  flow-next: finish
  flow-alternatives: []
  related: [verify, api, writing-quality]
---

# Docs

Generates the documentation the developer asked for — README, ADRs, changelog, runbook,
package docs, API docs — grounded in `specs/` and the actual source, never invented. It
re-reads the current `specs/` so the docs track reality, and it is hard-gated by
`writing-quality` before any artifact is written. On-request only: it does not run as part
of the default pipeline.

REQUIRED SUB-SKILL: `../writing-quality/SKILL.md` (HARD gate — documentation artifacts).

## Resolve what to write

Read `specs/MANIFEST.md`, `specs/architecture.md`, the feature `spec.md`/`plan.md`/
`contracts/` when present, and the source being documented (via `go doc` for package/API
surfaces). Confirm which artifact(s) the developer wants — never write a README, ADR,
changelog, or runbook that wasn't requested.

## Ground every claim

Every behavior claim must trace to a spec or to code. Separate confirmed behavior from open
questions; do not restate obvious code. If docs and code diverge, report the divergence as a
finding — do not silently rewrite broad docs or the canonical contract to match code.

- **API docs** — resolve the indexed contract in `specs/MANIFEST.md` (or
  `specs/<NNN>/contracts/`). Describe endpoints/schemas/status from that contract; route
  contract changes through `api` before updating derived docs. If docs are generated from
  annotations or schemas, update those sources, not only the generated output.
- **ADRs** — use for decisions future maintainers need: router choice, persistence strategy,
  module boundaries, auth model, queue semantics, migration tool, observability backend.
- **Runbooks** — operational procedures only: migrations, rollback, queue replay, incident
  checks, dashboard/log queries.
- **Changelog** — follow the project's existing changelog/release-notes convention; use
  `Added`/`Changed`/`Fixed`/`Migration` sections and do not invent versions or tags.

## Writing-quality gate (hard)

Before writing or committing any generated artifact, run the `writing-quality` scanners over
it. Confirmed slop is fixed first; a clean artifact is a byte-for-byte no-op — never "polish
anyway". Hard findings block the write; the artifact must pass the slop + preservation gates
before it lands.

## Write and index

Write the requested artifact. For a new living-spec doc, index it in `specs/MANIFEST.md`
and follow the `### [{task-name}] <Feature> (YYYY-MM-DD)` section convention; keep docs
task-scoped unless the developer asked to update a top-level README. Do not rewrite large
specs for a small post-baseline change — write a focused change doc instead.

Then STOP with Context Summary + Next Steps (route to `finish` when the feature is otherwise
complete).

## Common Rationalizations

- "I'll smooth the prose a bit while I'm in here." A rewrite with no confirmed slop is a
  byte-for-byte no-op; the scanners are the floor.
- "The code changed, so I'll update the contract to match." Divergence is a finding routed
  through `api`; docs never silently rewrite the canonical contract.
- "I'll generate a full README since I'm documenting anyway." Only the requested artifacts
  get written.

## Red Flags — STOP

- Writing a documentation artifact that wasn't requested.
- Writing a claim that traces to neither a spec nor the code.
- Bypassing the `writing-quality` hard gate on a generated artifact.
- Editing generated docs output instead of the annotation/schema source that produced it.
