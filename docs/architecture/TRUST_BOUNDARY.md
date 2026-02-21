# Trust Boundary

Decision summary (B, externalized MCP implementations):
1. This repository remains governance core only: deterministic, schema-enforced, auditable.
2. Real MCP implementations are outside this repo boundary.
3. This repo keeps only conformance assets for MCP validation.
4. Core execution path is `control-plane/go` + `audit-core/rust`.
5. Core release gate is never coupled to MCP implementation test outcomes.
6. MCP implementation volatility (network, time, credentials) is treated as extension risk.
7. Conformance runs in replay mode with offline fixtures.
8. Evidence integrity is verified by canonicalization + SHA-256.
9. `.legacy/hub` remains forbidden for execution path.
10. Any boundary exception requires explicit ADR approval.

## Boundary Definition

Core (inside trust boundary):
- `control-plane/go`
- `audit-core/rust`
- `schemas/jsonschema`
- `constitution/policies`
- `constitution/contracts`
- `constitution/cases`

Extensions (outside trust boundary):
- Remote/local MCP server implementations
- External integrations that require network, secret keys, or runtime clock dependence

Conformance-only assets (inside this repo, non-core):
- `conformance/**`
- `packages/mcps/**` (metadata/docs only, no executable remote MCP implementation)

## Prohibited in Core Path

- External network calls in governance core gate path
- Runtime clock as a decision input for policy verdict
- Randomized behavior in policy verdict path
- Secrets-bound execution tied to MCP implementation runtime
- Coupling core release outcome to extension implementation tests

## MCP Split Plan

- Implementation repositories live outside this repo, for example:
  - `../mcp-remote-*`
  - `../mcp-local-*`
- This repo validates implementation outputs via replayable conformance fixtures only.
- Each external MCP repo must publish:
  - manifest schema contract
  - replay fixture bundle
  - canonical output hash file for evidence verification
