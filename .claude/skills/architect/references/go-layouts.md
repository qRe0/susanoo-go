# Go Layout Reference

Use this when choosing or documenting `specs/architecture.md`. These are starting points,
not a rule list to clone — pick the lightest shape that protects the boundaries the repo
actually has, and record what was rejected.

## Standard Service

One deployable HTTP/RPC service with moderate complexity.

```text
cmd/<service>/main.go
internal/transport/http/     # handlers, middleware
internal/app/                # use cases, orchestration
internal/store/              # persistence
internal/platform/           # config, logging, telemetry
api/                         # generated contracts, if any
migrations/
```

Use when package boundaries help but strict layering is heavier than the problem.

## Package By Feature

Product work organized around user flows.

```text
internal/features/<feature>/
  handler.go
  service.go
  store.go
  model.go
  *_test.go
```

Move shared concepts out only after reuse is real. Cross-feature imports go through a
narrow public API, not into another feature's internals.

## Hexagonal / Ports And Adapters

Domain-heavy systems with replaceable adapters.

```text
internal/domain/
internal/application/
internal/adapters/http/
internal/adapters/postgres/
internal/platform/
```

Ports are small and owned by the consumer package. Do not build this shape unless an
adapter is actually going to be swapped or the domain genuinely outlives its plumbing.

## Modular Monolith

One deployable with separate business modules.

```text
internal/modules/users/
internal/modules/billing/
internal/modules/orders/
internal/platform/
```

Avoid cross-module imports that bypass module APIs; prefer explicit contracts or events.

## CLI / Worker

For CLIs and workers, HTTP packages may not exist.

```text
cmd/<tool>/
internal/commands/          # or internal/jobs/
internal/app/
internal/platform/
```

Document lifecycle, cancellation, config, logging, and exit codes — they are the interface.
