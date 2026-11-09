---
name: go-observability
user-invocable: false
description: Use when adding or reviewing logging, metrics, tracing, health checks, or diagnostics in Go services.
metadata:
  phase: reference
  related: [coder, code-reviewer, verify]
---

# Go Observability

An internal reference pulled by `coder` and `code-reviewer` when the change adds or reviews
logging, metrics, tracing, health checks, or operational diagnostics. It does not add a stage
or change the workflow.

Read and follow `specs/architecture.md` before choosing observability package placement,
transport instrumentation, or runtime lifecycle behavior.

REQUIRED SUB-SKILL: `../go-conventions/SKILL.md`.

## First pass

Identify the established stack: logging (`log/slog`, zap, zerolog, logrus, or a project
wrapper), tracing/metrics (OpenTelemetry, Prometheus, StatsD, cloud tooling, or none yet),
and the runtime type (HTTP API, gRPC service, worker, CLI, scheduled job). Follow the
existing stack unless the profile calls for a change.

## Logging

- Use structured logs with stable keys.
- Include request/job correlation IDs where available.
- Log at boundaries: request start/end, external calls, retries, background worker failures,
  startup/shutdown.
- Never log secrets, tokens, raw credentials, payment data, or unnecessary PII.
- Keep domain errors visible without dumping internals to clients.
- No `fmt.Println` or ad hoc logging in service code.

## Tracing

- Propagate `context.Context` through all I/O.
- Instrument inbound transports, outbound HTTP/RPC/database calls, queues, and major use-case
  boundaries.
- Set span attributes that help debugging without leaking sensitive data; record errors and
  status consistently.
- Avoid spans in tight loops unless sampling/cardinality is understood.

## Metrics

- Track RED/USE signals where relevant: request rate, errors, duration, saturation.
- Keep labels low-cardinality; never use user IDs, emails, raw paths, or unbounded values.
- Add business metrics only when actionable; expose runtime/process metrics if the deployment
  stack expects them.

## Health and readiness

- Liveness proves the process is alive; readiness checks the dependencies needed to serve.
- Keep health endpoints fast and bounded by context/timeouts.
- For workers, expose heartbeat, queue lag, or last-success signals when practical.

## Verification

- Test logger/tracer/metric hooks when behavior matters; confirm logs and metrics reach the
  expected sink when feasible; review high-cardinality and secret-leakage risk.
- Run the applicable `.claude/DOD.md` tier; the `verify` stage owns the final ops gate.

## Common Rationalizations

- "I'll add observability after it works." Instrumentation added later is retrofitted and
  inconsistent; log and trace at boundaries as the code lands.
- "A log line per request is enough." Correlation IDs and structured fields are what make logs
  queryable; unstructured lines do not scale to a real incident.
- "High-cardinality labels are fine for now." Unbounded labels break metric backends; keep
  them low-cardinality from the start.

## Red Flags — STOP

- `fmt.Println` or ad hoc logging in service code.
- Secrets, tokens, or PII in a log line, span attribute, or metric label.
- A liveness/readiness check that hits an external dependency and can hang.
