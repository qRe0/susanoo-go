---
name: test-generator
description: Use to add or update Go tests — table-driven unit tests, httptest handler tests, testcontainers-go integration, race checks, and failure analysis — when a concrete coverage gap exists.
metadata:
  phase: execution
  flow-next: code-reviewer
  flow-alternatives: [coder]
  related: [coder, code-reviewer]
---

# Test Generator

Adds meaningful Go tests matching the repo's architecture profile and local conventions.
Prefer standard `testing`; use `testify` only if already established. If existing tests
already cover the confirmed behavior, leave them unchanged and report that finding. Assess
coverage even when no gap is known; add tests only for a confirmed gap. Without TDD this
stage follows `coder` and owns test authoring; under TDD, coverage gaps return to `coder`.

REQUIRED SUB-SKILLS: `../go-conventions/SKILL.md`, `../test-audit/SKILL.md`.

## First read

- `../test-audit/SKILL.md` for every new or changed test.
- `specs/architecture.md`, `specs/MANIFEST.md`, and relevant task/spec docs.
- Neighboring `*_test.go` files and the project's test commands in `Makefile`/`Taskfile`/CI.

Tests verify confirmed behavior, not assumptions; unclear requirements route back to the
user, not into guessed tests. Tests added after implementation improve coverage but do not
retroactively establish a RED phase.

## Test types

| Need | Approach |
|---|---|
| Business rules | table-driven unit tests |
| HTTP behavior | `httptest.NewRequest` + `httptest.ResponseRecorder` (assert status, headers, shape) |
| gRPC/connectrpc | in-process server/client tests + status mapping |
| SQL/transactions | integration tests with a test DB or testcontainers-go |
| Migrations | apply/rollback/drift where project tooling supports it |
| CLI behavior | command tests with fake stdin/stdout and temp dirs |
| Concurrency | deterministic coordination + `go test -race` |

Unit tests stay runnable without external services; isolate integration tests behind an
`//go:build integration` tag (or the project's existing tag).

## testcontainers-go

Use when the repo already uses it or integration needs real dependencies. Rules:
`context.WithTimeout` for startup/queries, `t.Cleanup` for teardown, readiness waits (not
sleeps), minimal deterministic fixtures, per-test isolation, skip only per project
convention (tag off or Docker unavailable).

## Rules

- Deterministic: no unbounded sleeps, wall-clock dependence, or shared mutable fixtures.
- Prefer tiny behavior-focused fakes over broad mocks; use `t.TempDir()`/`t.Cleanup()`.
- Do not skip failing tests to go green; do not weaken assertions because implementation is
  hard; do not add tests for behavior requirements did not confirm.

## Failure analysis

When a test fails: capture the exact command and the smallest useful excerpt; classify as
implementation bug (route to `coder`), test bug (fix the assertion here when the contract
requires it), environment/setup, or unclear requirement. Route unclear root causes to
`systematic-debugger`.

## Verification

Run focused and package tests for the changed behavior, then the applicable Standard
`.claude/DOD.md` tier with the repo's runner. Record exact commands and results; report
`NOT RUN` with reason for expensive or environment-dependent checks. Then STOP with Context
Summary + Next Steps.

## Common Rationalizations

- "Coverage percentage is the goal." A test that protects no contract is nothing even when
  it turns a line green; value first.
- "I'll mock the store to keep it fast." A mock that supplies the asserted behavior proves
  nothing; prefer a real fake or an integration test at the DB boundary.
- "It overlaps another test but it's harmless." Overlap costs maintenance; extend one
  table-driven case instead of duplicating a scenario.

## Red Flags — STOP

- An assertion-free probe, or an expected value computed by the code under test.
- A mock that returns the exact behavior being asserted.
- Skipping a failing test to make the suite green, or weakening an assertion to pass.
- Claiming a retroactive RED from tests added after implementation.
