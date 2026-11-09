---
name: api
description: Use when a feature has an API, event, or DTO contract surface — design the REST/RPC/event contract (endpoints, schemas, validation, errors, pagination, versioning) into specs/<NNN>/contracts/ before implementation.
metadata:
  phase: planning
  flow-next: specify
  flow-alternatives: []
  related: [architect, specify, plan, coder, code-reviewer]
---

# Api

Designs the contract surface a feature exposes — REST/HTTP, gRPC/connectrpc, webhook, or
event — before implementation. It produces contract sources, not product code; the
implementation work belongs to `coder`. Run this stage only when the feature has a contract
surface; skip it for purely internal changes.

## Route to architect first

The contract must fit `specs/architecture.md` (transport, router/RPC framework, generated
code placement, package boundaries). If that profile is missing or does not choose a
transport, stop and route to `architect` — never invent the router, RPC framework, or
generated-code layout here.

## Determine the feature directory

Resolve the current feature via `scripts/check_prerequisites --json --paths-only`
(`FEATURE_DIR`). If `specify` has already allocated the feature, use its directory. If no
feature directory exists (a contract-first entry point), run
`scripts/new_feature --json <description>` to allocate it — do not hand-create the directory
or invent a number. Contracts live under `specs/<NNN>/contracts/`.

## Choose the transport

| Transport | Use when | Contract artifact |
|---|---|---|
| REST/JSON over HTTP | Public APIs, browser/mobile clients, resource workflows | OpenAPI or a route/schema spec |
| gRPC | Internal service-to-service, streaming, strict typed contracts | `.proto` + generated Go placement |
| connectrpc | RPC semantics with HTTP/browser compatibility | `.proto` + connect handlers/clients |
| Webhook receiver | Third-party callbacks | signed-endpoint spec + replay/idempotency rules |
| Event API | Async integration | event schema, delivery semantics, consumer contract |

Do not choose RPC because it is fashionable. REST fits resources and HTTP semantics; gRPC
fits typed service contracts, streaming, or real internal-service boundaries.

## REST/HTTP design

Resource-oriented: plural lowercase resources, hyphens for multi-word names, IDs in the
path, filtering/pagination/sorting in query params. Version public APIs deliberately
(default `/api/v1` unless the profile chooses otherwise). Keep business actions explicit as
sub-resources (`/cancel`, `/approve`) when CRUD is not enough; use idempotency keys for
externally retried create/payment/webhook flows.

Status codes: list/read 200 (404 for missing single resource); create 201 with `Location`;
replace/update 200/204 (409 for conflicts); delete 204 (idempotent where possible); async
accepted 202. Errors: 400 validation, 401 unauthenticated, 403 forbidden, 404 not found,
409 conflict, 422 semantic validation, 429 rate limit, 500 unexpected. Define one consistent
error shape; prefer RFC 9457-style fields when no local standard exists.

Request and response structs are explicit boundary types — never bind directly to
persistence models or domain aggregates. Separate request structs from response structs;
never expose secrets, internal flags, tenant IDs, or server-managed fields as
client-settable; document optional vs required and how absence differs from explicit null
(pointer fields, nullable types, JSON patch, or field masks).

## Validation, pagination, versioning

Validation belongs at the transport boundary before domain logic: required fields, length
and format, numeric bounds, enum allowlists, cross-field rules, tenant/ownership source,
conflict and idempotency rules. Domain code still protects business rules — handlers do not
hold domain invariants.

For list endpoints specify pagination style (limit/offset, cursor, page token), default and
max page sizes, stable sort order, supported filters and operators, empty-result behavior,
and total-count behavior. Prefer cursor/page-token for large mutable collections.

## gRPC / connectrpc / webhooks

For RPC: define service contracts before handlers — proto package and Go package option,
generated-code location and regeneration command, service/method names and versioning,
request/response messages, error mapping to status/connect codes, deadlines/timeouts and
cancellation, streaming semantics, auth metadata and tenant rules, and backward-compat rules
(field numbers, reserved fields, enum evolution). Do not expose storage/domain structs as
protobuf messages unless the profile accepts that coupling.

For webhook receivers: provider event types, signature verification and timestamp
tolerance, idempotency/event-id storage, retry behavior and response semantics, ordering
assumptions, dead-letter/manual replay, and test-mode fixtures.

## Write and index the contract

Write the contract sources under `specs/<NNN>/contracts/` (`.proto`, `.yaml`, or event
schemas). If the project already owns a canonical OpenAPI or `.proto` contract, update and
index that source instead of duplicating it. Index every contract surface in
`specs/MANIFEST.md` so `plan`, `coder`, `test-generator`, `code-reviewer`, `verify`, and
`docs` can find it. Never hand-edit generated code (gRPC comes from `.proto`, sqlc from
SQL); this stage only authors the source contract.

Include per surface: endpoints/RPC methods, schemas/messages, validation, auth/security,
error semantics, pagination, compatibility, and the contract tests to write. Note the
regeneration command for any generated output.

Then STOP with Context Summary + Next Steps (route to `specify` for the WHAT/WHY spec, or
to `plan` if the spec already exists).

## Common Rationalizations

- "I'll bind the handler directly to the persistence model." Boundary types are the
  contract; coupling them to storage leaks schema into the API and blocks evolution.
- "RPC is modern, I'll default to gRPC." Transport is a decision the profile makes against
  real requirements, not a default.
- "I'll write the handler now so the contract is concrete." This stage authors the contract
  source; implementation is `coder`'s job.

## Red Flags — STOP

- Designing a contract when `specs/architecture.md` is missing or silent on transport.
- Hand-editing generated code, or authoring only generated output instead of the source.
- Exposing secrets, tenant IDs, or server-managed fields as client-settable.
- Writing the same contract in two places instead of updating the canonical source.
