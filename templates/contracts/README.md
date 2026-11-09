# Contracts

Per-feature contract sources live under `specs/<NNN>-<short-name>/contracts/`, written by
the `api` stage (or Phase 1 of `plan` when no separate API stage runs). They are the
source of truth for the feature's external surface. Group them by module or API surface.

## Formats

- **RPC**: protobuf (`.proto`), generated with `buf` or `protoc`.
- **REST**: OpenAPI (`.yaml`), validated by the project's OpenAPI tooling.
- **Events**: JSON schema for published/consumed messages.

## What a contract records

- Endpoints or RPC methods, with request/response schemas.
- Validation and error semantics.
- Authorization boundaries.
- Pagination and compatibility rules.
- Contract tests that pin the surface.

Index each contract in `specs/MANIFEST.md`. If the repository already owns an OpenAPI or
`.proto` contract, use and index that source instead of duplicating it.

## Minimal examples

```proto
syntax = "proto3";

package example.v1;

service ExampleService {
  rpc GetExample(GetExampleRequest) returns (GetExampleResponse);
}

message GetExampleRequest {
  string id = 1;
}

message GetExampleResponse {
  string id = 1;
  string name = 2;
}
```

```yaml
openapi: 3.0.3
info:
  title: Example API
  version: 0.1.0
paths:
  /examples/{id}:
    get:
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      responses:
        "200":
          description: OK
```
