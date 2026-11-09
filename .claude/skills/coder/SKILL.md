---
name: coder
description: Use to implement a task from the plan and architecture profile — package boundaries, handler/service patterns, storage, migrations, generated code, context/error handling, and concurrency.
metadata:
  phase: execution
  flow-next: code-reviewer
  flow-alternatives: [test-generator]
  related: [architect, test-driven-development, test-generator, code-reviewer]
---

# Coder

Implements the `implement` stage: code produced per task, TDD-red/green where the project
chose TDD, each task reviewed before the next. `specs/architecture.md` decides package
placement, dependencies, selected libraries, generated-code directories, migration tooling,
and verification commands — if it is missing, stop and route to `architect`.

REQUIRED SUB-SKILLS: `../go-conventions/SKILL.md`, `../test-audit/SKILL.md`,
`../ponytail/SKILL.md`. Load `../test-driven-development/SKILL.md` within this stage only
when TDD applies (see below).

## TDD mode

Read the profile's TDD mode before a behavior change or bug fix.

- `required`, or the task explicitly opts in → load `test-driven-development`, write the
  test first, and record observed RED/GREEN evidence in the handoff.
- `on request` / `not adopted` and no opt-in → implement without writing or changing tests;
  run existing tests, then hand test gaps and contract-aligned outdated assertions to
  `test-generator`.
- Mode absent → suggest `architect` records a decision; do not assume TDD. All modes still
  require the applicable `.claude/DOD.md` test gates.

## Workflow

1. Read neighboring code, package boundaries, and existing test style.
2. Identify the smallest behavior slice.
3. Plan files/imports and check import-cycle risk.
4. With TDD, write a focused test and observe a behavior-driven RED. Without TDD, do not
   write or change tests.
5. Implement boring Go matching local patterns; with TDD, observe GREEN and refactor under
   passing tests.
6. Run focused checks, then package/repo checks.
7. Summarize changed behavior, verification, and next risks.

## Package boundaries

- Keep domain/application code free of transport framework types.
- Keep `*http.Request`, framework contexts, protobuf/connect wrappers, SQL rows, and
  generated DB models at the boundary the profile selects.
- Prefer fewer packages until boundaries are real; do not create `pkg/` unless the code is
  intentionally public.
- Own small interfaces at the consumer boundary; avoid import cycles by moving shared
  contracts downward.

## Implementation rules

- `context.Context` first parameter for I/O; never stored in structs.
- Return errors; wrap with `%w`; classify with `errors.Is`/`errors.As`.
- Handlers thin: decode, validate, authorize/scope, call, encode.
- Transactions explicit and visible at the use-case/store boundary.
- No mutable global state for DB handles, loggers, or config.
- Goroutines with owner, cancellation, bounded concurrency, and error collection.
- Prefer standard library unless the profile selects a library.
- Generated code stays generated: change the source schema/query/proto and regenerate.

## Patterns

HTTP handler: decode → validate → call the consumer-owned interface → encode, mapping
errors to a stable response shape. RPC handler: validate at the boundary, convert protobuf
messages to application input structs, map errors to stable status codes, preserve request
deadline/cancellation. Service/use case: domain constructors validate invariants, services
orchestrate I/O and transactions, pure domain functions do not require `context.Context`,
and time/randomness/external deps are injected where tests need control.

## Storage, migrations, generated code

- Parameterized queries or generated query methods; explicit transaction ownership with
  rollback on error.
- Schema changes use the migration tool from the profile, with forward and rollback/down
  behavior when the tool supports it; never hand-edit generated migration output.
- Before touching generated code, find the source of truth (sqlc ← SQL, protobuf ← proto,
  OpenAPI ← spec, mocks ← generator config) and regenerate; if no generate command exists,
  report the gap, do not invent one.

## Pre-completion

Run the applicable `.claude/DOD.md` tier with the repository's documented runners; record
exact commands and results. Without TDD, mark new-test coverage pending `test-generator`
and do not claim the final DoD passed. If `go mod tidy` changes `go.mod`/`go.sum`, explain
why; investigate unexpected changes before finishing.

Then STOP with Context Summary + Next Steps (with TDD evidence when TDD applied).

## Common Rationalizations

- "I'll add the test after the code is stable." Under TDD the failing test comes first; a
  test written after is coverage, not TDD evidence.
- "This needs an interface for testability." Add the interface at the consumer boundary
  when a test needs it, not preemptively next to every concrete type.
- "A quick hand-edit of the generated file is fine." Generated code is regenerated from its
  source; a hand-edit is silently lost on the next generate.

## Red Flags — STOP

- Writing or changing tests when TDD does not apply (that belongs to `test-generator`).
- Claiming completion with failing tests, or manufacturing a RED for an already-passing
  behavior.
- Leaking framework/DB/generated types into domain packages.
- Editing generated files by hand, or inventing a generator command.
