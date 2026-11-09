---
name: go-api
user-invocable: false
description: Use when implementing or reviewing Go HTTP/RPC surfaces — handlers, middleware, DTOs, error mapping, routing, and contract compatibility.
metadata:
  phase: reference
  related: [coder, test-generator, code-reviewer, api, go-security]
---

# Go API

An internal reference pulled by `coder`, `code-reviewer`, and `test-generator` when the
change touches an HTTP or RPC surface. It does not add a stage or change the workflow; the
stage that invoked it finishes with its own Context Summary + Next Steps.

Read and follow `specs/architecture.md` before choosing package placement, router/framework
behavior, generated-code conventions, or transport boundaries. Read `specs/MANIFEST.md` and
the indexed contract under `specs/<NNN>-<short-name>/contracts/`; if no indexed contract
covers the surface, stop and route to the `api` stage. Report divergence from the contract
as a finding — never silently edit the contract.

REQUIRED SUB-SKILLS: `../go-conventions/SKILL.md`, `../test-audit/SKILL.md`. TDD is
governed by `coder` through `../test-driven-development/SKILL.md`; this reference does not
impose or waive it.

## First pass

Identify the transport and framework before changing code:

- Transport: standard library `net/http`, a router (chi, gin, echo, fiber, httprouter), or an
  RPC protocol (gRPC, connectrpc, Twirp, JSON-RPC).
- Contract: OpenAPI, `.proto`, or a canonical spec indexed in `specs/MANIFEST.md`.

Do not switch frameworks unless the profile or the task requires it.

## HTTP rules

- Keep handlers thin: decode, validate, call the use case, encode.
- Take `context.Context` from the request and pass it through every I/O boundary.
- Centralize error mapping where the framework allows; return a stable error shape with a
  machine-readable code when clients depend on it.
- Enforce body size limits and server read/write/header/idle timeouts.
- Order middleware intentionally: request ID, logging, recovery, auth, rate limits, body
  limits, CORS, tracing.
- Never leak internal errors, SQL, stack traces, tokens, or secrets.

## Router notes

- `net/http`: explicit handlers and middleware; avoid global mutable registries.
- chi: readable route groups; middleware local to the scope that needs it.
- gin/echo/fiber: bind and validate input explicitly; do not let framework context leak into
  business packages.
- Any router: keep route registration discoverable from server setup.

## RPC rules

- Treat `.proto` files as contracts; keep generated code generated — change the source and
  regenerate, never hand-edit output.
- Map domain errors to stable status codes.
- Preserve compatibility: add fields, never reuse field numbers, reserve removed fields.
- Use interceptors for auth, logging, tracing, validation, and recovery.

## DTOs and validation

- Separate transport DTOs from persistence rows and domain objects when coupling would leak
  details.
- Validate required fields, enums, limits, timestamps, IDs, and cross-field invariants at the
  edge; prefer explicit parsing for IDs and times.
- Keep response fields stable and documented.

## Compatibility checklist

- Route/method/path/status changes are intentional and recorded in the contract.
- OpenAPI or `.proto` output is regenerated when the source changes; generated clients and
  servers are regenerated when needed.
- Pagination, filtering, and sorting semantics stay stable.
- Deprecated fields/endpoints carry migration notes.

## Verification

- Unit-test handlers with `httptest` (or framework helpers); cover auth and validation
  failure paths; test error-to-status mapping. For RPC, test handler/client behavior and
  compatibility-sensitive errors through generated interfaces where practical.
- Apply the `test-audit` value questions to every new or changed test; run the applicable
  `.claude/DOD.md` tier with the repo's runners.

## Common Rationalizations

- "The framework maps errors for me." A default 500 without a stable shape breaks clients
  that depend on machine-readable codes; centralize the mapping deliberately.
- "I'll return the domain struct directly." Coupling transport output to persistence rows
  leaks schema details into the public API; add a DTO when the boundary is public.
- "It's a minor route change, no contract update needed." Any route/method/status change is
  part of the contract; update and regenerate before finishing.

## Red Flags — STOP

- Editing generated `.proto`/OpenAPI output by hand.
- A handler that decodes, queries, mutates, and encodes all in one function.
- Leaking an internal error, stack trace, or secret to a client.
- Silently changing a public API without updating the indexed contract.
