# MCP Ownership Policy v0.1

## Purpose

Define a clear ownership split so service teams can move fast without fragmenting MCP contracts.

## Ownership Model

- Central governance (`ai-governance`) owns:
  - MCP IDs and capability contracts
  - Risk tier and approval tier mapping
  - Registry and pinned reference hash policy
- Service repositories own:
  - Runtime adapters/clients that invoke approved MCP contracts
  - Service-local wiring (auth header, timeout, retry, trace propagation)

## Non-Negotiable Rules

- MCP IDs must use `core-*` naming in central registry and service allowlists.
- `pinned_ref_hash` must point to a deterministic runtime binding artifact.
- Service repositories must not create independent MCP contract IDs that bypass central registry.
- Capability addition/removal is a central governance change and must update:
  - `control/registry/mcps.v0.1.json`
  - MCP manifest
  - service allowlist(s)

## Service-Scoped MCP Exception

- Service-only MCP is allowed only as temporary transition.
- It must be marked as transitional and have deprecation date and migration plan to `core-*`.
