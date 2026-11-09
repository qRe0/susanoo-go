---
name: go-concurrency
user-invocable: false
description: Use when writing or reviewing goroutines, channels, shared state, cancellation, or race-sensitive Go code.
metadata:
  phase: reference
  related: [coder, code-reviewer, test-generator]
---

# Go Concurrency

An internal reference pulled by `coder` and `code-reviewer` when the change touches
goroutines, fan-out/fan-in, channels, shared state, background workers, or race-sensitive
paths. It does not add a stage or change the workflow.

Read and follow `specs/architecture.md` before changing lifecycle, worker ownership, package
boundaries, or project-specific concurrency patterns. Structural invariants (goroutine
ownership, cancellation, error paths) live in `.claude/GOLDEN-PRINCIPLES.md`; detailed rules
(`goroutine-forget.md`, `goroutine-exit.md`, `goroutine-init.md`, `channel-size.md`,
`atomic.md`, `mutex-zero-value.md`) live in `.claude/conventions/` and are applied through
`go-conventions` — this file points at them, never restates them.

REQUIRED SUB-SKILLS: `../go-conventions/SKILL.md`, `../test-audit/SKILL.md`. TDD is
governed by `coder` through `../test-driven-development/SKILL.md`.

## First pass

Identify the concurrency shape before changing code:

- Is the work request-scoped, process-scoped, or service-lifecycle scoped?
- Who owns each goroutine and how does it stop?
- Where do errors go?
- What bounds concurrency, queue length, memory growth, and retry loops?
- Which tests can prove cancellation, timeout, and race behavior?

## Core rules

- Every goroutine has an owner, a cancellation path, and an error path.
- Prefer `errgroup.WithContext` for request-scoped parallel work.
- Channels for ownership transfer; mutexes for shared mutable state; atomics only for narrow
  counters/flags.
- Bound worker pools, fan-out, retries, and queue sizes.
- Stop tickers and timers; close response bodies; drain or cancel work intentionally.
- Do not store request contexts in structs for later background use.
- Never use `time.Sleep` to coordinate tests — use channels, contexts, wait groups, fake
  clocks, or hooks.
- Run the applicable race check from `.claude/DOD.md` for concurrency-heavy changes.

## Patterns

### Request-scoped parallelism

Use `errgroup.WithContext`; pass the derived context to all child calls; return the first
meaningful error; avoid shared result variables without a mutex or per-result channel.

### Background workers

Start workers from an explicit lifecycle boundary (`main`, server setup, or a worker runner);
accept `context.Context` and return errors through a caller-visible path; use bounded queues
and explicit shutdown; make retry/backoff configurable and testable.

### Channels

The sender usually owns closing; do not close from the receiver unless ownership is explicit;
prefer directional channel parameters; prefer a mutex when the problem is shared memory, not
ownership transfer.

### Shared state

Keep lock scope small and visible; never do slow I/O while holding a mutex; use `sync.Map`
only for its documented access patterns; avoid clever atomics unless the invariant is simple
and documented.

## Review checklist

- Can every goroutine exit on cancellation?
- Are sends and receives protected from permanent blocking?
- Are worker counts and queue sizes bounded? Are errors observable?
- Are tests deterministic without sleeps? Was `-race` run or marked `NOT RUN` with a reason?

## Common Rationalizations

- "It works under load in dev." Concurrency bugs are timing-dependent; a race that does not
  reproduce is still a race — run `-race` and reason about ownership, not timing.
- "A buffered channel makes it safe." Buffering hides a blocking bug; it does not remove the
  need for ownership and cancellation.
- "A `time.Sleep` in the test is fine." Sleeps mask the very race the test should expose; use
  channels, contexts, or hooks.

## Red Flags — STOP

- A goroutine with no owner, stop signal, or error path.
- A channel closed by the receiver, or a send that can block forever.
- `time.Sleep` used to coordinate tests, or `-race` skipped without a recorded reason.
