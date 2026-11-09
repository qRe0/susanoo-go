# Tasks: [FEATURE NAME]

**Input**: Design documents from `specs/[NNN-feature-name]/`

**Prerequisites**: `plan.md` (required), `spec.md` (required for user stories),
`research.md`, `data-model.md`, `contracts/`

**Tests**: List tests before the implementation they cover, inside the same story, so they
fail first. Include test tasks only when the project's recorded TDD practice requires them
or the spec asks for them.

**Organization**: Tasks are grouped by user story so each story can be implemented,
tested, and delivered on its own.

## Format: `- [ ] T### [P] [US#] Description`

- **T###**: Sequential task ID, zero-padded (`T001`, `T002`, ...).
- **[P]**: Mark tasks that can run in parallel (different files, no dependencies).
- **[US#]**: The user story this task belongs to (`US1`, `US2`, ...).
- Description names the exact file path.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure.

- [ ] T001 Create the package layout per `plan.md`
- [ ] T002 Initialize the Go module and primary dependencies from `plan.md`
- [ ] T003 [P] Configure formatting and linting (`gofmt`, `goimports`, `golangci-lint`)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that must exist before any user story can be implemented.

**CRITICAL**: No user story work begins until this phase is complete.

- [ ] T004 Set up database schema and migrations framework
- [ ] T005 [P] Implement the router and middleware structure
- [ ] T006 [P] Set up configuration loading and structured logging
- [ ] T007 Create base types that all stories depend on

**Checkpoint**: Foundation ready. User story implementation can begin.

---

## Phase 3: User Story 1 - [Title] (Priority: P1) MVP

**Goal**: [What this story delivers.]

**Independent Test**: [How to verify this story works on its own.]

### Tests for User Story 1

> Write these tests first and confirm they fail before implementing.

- [ ] T010 [P] [US1] Test [behavior] in `internal/[pkg]/[file]_test.go`
- [ ] T011 [P] [US1] Handler test for [endpoint] in `internal/httpapi/[file]_test.go`

### Implementation for User Story 1

- [ ] T012 [P] [US1] Add [Entity1] type in `internal/[pkg]/[entity1].go`
- [ ] T013 [P] [US1] Add [Entity2] type in `internal/[pkg]/[entity2].go`
- [ ] T014 [US1] Implement [Service] in `internal/[pkg]/[service].go` (depends on T012, T013)
- [ ] T015 [US1] Implement [handler] in `internal/httpapi/[file].go`
- [ ] T016 [US1] Add validation and error handling

**Checkpoint**: User Story 1 is fully functional and testable on its own.

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [What this story delivers.]

**Independent Test**: [How to verify this story works on its own.]

### Tests for User Story 2

- [ ] T020 [P] [US2] Test [behavior] in `internal/[pkg]/[file]_test.go`

### Implementation for User Story 2

- [ ] T021 [P] [US2] Add [Entity] type in `internal/[pkg]/[entity].go`
- [ ] T022 [US2] Implement [Service] in `internal/[pkg]/[service].go`
- [ ] T023 [US2] Implement [handler] in `internal/httpapi/[file].go`

**Checkpoint**: User Stories 1 and 2 both work independently.

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories.

- [ ] TXXX [P] Update documentation in `docs/`
- [ ] TXXX Clean up and refactor
- [ ] TXXX [P] Add missing unit tests in `internal/[pkg]/[file]_test.go`
- [ ] TXXX Run `quickstart.md` validation end-to-end

---

## Dependencies & Execution Order

- **Setup (Phase 1)**: no dependencies, start immediately.
- **Foundational (Phase 2)**: depends on Setup, blocks all user stories.
- **User Stories (Phase 3+)**: depend on Foundational; run in priority order (P1, P2, ...)
  or in parallel if staffed.
- **Polish (final phase)**: depends on the desired stories being complete.
- Within a story: tests fail first, types before services, services before handlers, and
  the story completes before the next priority begins.
- `[P]` tasks touch different files with no dependency, so they can run in parallel.

## Notes

- Each user story must be independently completable and testable.
- Verify tests fail before implementing.
- Run `gofmt` on touched Go files and pass the package tests before ticking a task.
- Commit after each task or logical group.
- Avoid vague tasks, same-file conflicts, and cross-story dependencies that break independence.
