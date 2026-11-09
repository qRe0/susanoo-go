# Go Transport Reference

Use this when choosing the transport layer in `specs/architecture.md`.

## HTTP Routers

| Choice | Use when | Notes |
|---|---|---|
| `net/http` | Simple services, minimal dependencies, Go 1.22+ method/path routing | Default unless route grouping/middleware ergonomics require more |
| `chi` | REST service with middleware, route groups, path params | Small, idiomatic, common default for non-trivial HTTP |
| `gin` | Existing gin codebase or team preference | Fast and popular; keep framework types out of domain |
| `echo` | Existing echo codebase or middleware ecosystem fit | Avoid framework leakage past handlers |
| `fiber` | Existing fiber codebase only | Not `net/http` based; verify middleware/tooling compatibility |

## RPC

| Choice | Use when | Notes |
|---|---|---|
| gRPC | Internal service-to-service APIs, streaming, typed contracts | Requires protobuf lifecycle and generated-code rules |
| connectrpc | Browser-friendly and Go-friendly RPC over HTTP | Good when gRPC semantics are wanted with simpler HTTP compatibility |
| JSON-RPC / custom RPC | Existing protocol or narrow internal need | Document errors, versioning, and compatibility carefully |

## Boundary Rules

- Transport packages decode, validate transport shape, authorize/scope, call
  application/domain code, and map results.
- Framework request/context types do not enter domain packages.
- Generated transport code lives in a documented `api/`, `gen/`, or profile-selected package.
- Public contracts require compatibility rules and contract tests.
