---
name: go-composition
user-invocable: false
description: Use when wiring packages, dependencies, configuration, constructors, and interfaces in Go — or reviewing them.
metadata:
  phase: reference
  related: [coder, code-reviewer, architect]
---

# Go Composition

An internal reference pulled by `coder` and `code-reviewer` when the change wires packages,
dependencies, configuration, constructors, or interfaces. It does not add a stage or change
the workflow.

Read and follow `specs/architecture.md` before changing package boundaries, dependency
direction, configuration ownership, or wiring style.

REQUIRED SUB-SKILLS: `../ponytail/SKILL.md`, `../go-conventions/SKILL.md`.

## First pass

Map the current package shape before adding abstractions: entrypoints (`cmd/*`, server or
worker bootstrap, CLI root), domain/application vs infrastructure packages, the existing
constructor style, configuration loading and validation, and whether the project uses
manual wiring, `wire`, `fx`, or another container.

## Core rules

- Dependencies are explicit constructor parameters.
- Interfaces are defined by consumers when they need a boundary.
- No one-interface-per-struct boilerplate.
- Configuration is typed and validated at startup.
- Prefer simple manual wiring; use `wire`/`fx` only if the project already uses it or the
  profile chooses it.
- Avoid package cycles by moving contracts to the consumer side or narrowing responsibilities.

## Package boundaries

- Packages describe capabilities, not layers for their own sake.
- Keep exported names minimal and stable.
- Avoid `internal/common`, `pkg/utils`, and shared dumping grounds unless the repo already
  has clear rules for them.
- Let infrastructure depend inward on domain/application contracts, not the reverse.
- Keep transport DTOs separate from persistence rows when coupling would leak details.

## Interfaces

- Define an interface only when there is more than one implementation, a real test seam, or a
  package boundary that requires it.
- Keep interfaces small and behavior-focused; place them near the consumer.
- Do not export an interface just because an implementation is exported.

## Configuration

- Load environment/files/flags at the edge; convert raw config to typed structs before wiring.
- Validate required fields, URLs, durations, pool sizes, feature flags, and secrets at startup.
- Keep test defaults explicit and local to tests.

## Constructors and lifecycle

- Constructors validate dependencies and return ready-to-use values.
- Long-running components need an explicit `Start`/`Run`/`Stop` or context-driven lifecycle.
- Avoid hidden goroutines in constructors unless documented and cancellable.
- Defer cleanup in the same layer that creates the dependency.

## Review checklist

- Is the package graph acyclic and understandable?
- Are interfaces justified and located at the right boundary?
- Is config validated before serving traffic?
- Are constructors simple and testable? Does wiring match the profile?

## Common Rationalizations

- "An interface for every type is good design." One-interface-per-struct is boilerplate that
  adds a seam nobody uses; add it at the consumer when a boundary needs it.
- "`wire`/`fx` will scale better." Manual wiring is simple and grep-able; a container is only
  justified when the repo already uses one or the profile chose it.
- "Put helpers in `pkg/utils`." A shared dumping ground hides where behavior belongs; prefer
  capability-named packages.

## Red Flags — STOP

- A constructor that spawns a hidden, uncancellable goroutine.
- A new abstraction, package, or interface with no real boundary or consumer.
- Config read and used untyped before validation, or a secret passed around as a string.
