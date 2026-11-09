---
name: go-security
user-invocable: false
description: Use for security-sensitive Go changes or reviews — auth, secrets, crypto, input parsing, webhooks, and dependency/IaC safety.
metadata:
  phase: reference
  related: [coder, code-reviewer, go-api, go-data]
---

# Go Security

An internal reference pulled by `coder` and `code-reviewer` for security-sensitive Go work.
It does not add a stage or change the workflow. Hard security rules live in `AGENTS.md` →
Security; verification gates in `.claude/DOD.md`; this file points at both, never restates
them.

Read and follow `specs/architecture.md` before changing auth boundaries, package ownership,
data-access protections, or cloud/payment guardrails.

REQUIRED SUB-SKILLS: `../go-conventions/SKILL.md`, `../test-audit/SKILL.md`.

## First pass

Classify the risk area: authentication/session/token handling; authorization, tenant
isolation, or IDOR; input parsing, file upload, SSRF, redirects, CORS, or CSRF; SQL/data
access and secrets; webhooks, payments, cloud credentials, IaC, or supply chain.

## Web security

- Enforce authentication at middleware or route-group boundaries; keep authorization checks
  close to the use case that owns the resource.
- Validate path/query/body input explicitly; bound request body size and parsing cost;
  configure HTTP server timeouts.
- Keep CORS explicit — no wildcard origins with credentials; use secure cookie attributes
  (`HttpOnly`, `Secure`, `SameSite`); protect cookie auth from CSRF.
- Return safe errors to clients; detailed errors only to trusted logs.

## Data and secrets

- Use parameterized SQL and established query builders correctly; dynamic SQL only with
  allowlisted identifiers.
- Never log secrets, tokens, authorization headers, raw payment payloads, or private keys.
- Load secrets from the project-approved source; never commit `.env`, credentials, private
  keys, or cloud config with secrets.

## Crypto and tokens

- Standard library or trusted libraries only — no custom crypto.
- Constant-time comparison for secrets and signatures.
- Validate JWT issuer, audience, expiry, algorithm, and key rotation assumptions; use enough
  entropy for generated tokens.
- Hash passwords with a password hashing algorithm (bcrypt, scrypt, argon2id) per the
  project's choice.

## Webhooks and payments

- Verify provider signatures before parsing trust-sensitive data; check timestamps/nonces for
  replay protection; implement idempotency for retried events.
- Separate test/live credentials and environments; log provider event IDs, not raw payloads.

## Dependencies and cloud

- Prefer maintained packages with clear provenance; run the vulnerability check from
  `.claude/DOD.md` when security-sensitive dependencies change.
- Review IAM permissions, public exposure, storage buckets, network rules, and destructive
  Terraform/IaC changes. Treat payment, auth, and cloud changes as high-review areas.
- Do not run destructive cloud/K8s/IaC/payment operations without explicit user consent
  (see `AGENTS.md`).

## Verification

- Add tests for unauthorized, forbidden, malformed, replayed, and boundary inputs.
- Confirm secrets do not appear in logs or fixtures; mark security scans PASS/FAIL/NOT RUN/N/A.

## Common Rationalizations

- "It's an internal endpoint, auth can wait." Internal endpoints are still reachable and still
  need auth; the boundary does not change the rule.
- "A shared secret in the repo is convenient." Committed secrets are compromised secrets;
  load from the approved source or rotate immediately.
- "Custom crypto for a simple hash." Custom crypto is broken by default; use a standard
  password hashing function.

## Red Flags — STOP

- String-built SQL, or a secret/token/header in a log line or fixture.
- Custom crypto or a non-constant-time secret comparison.
- A webhook/payment handler that processes a payload before verifying its signature.
