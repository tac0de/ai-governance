# SERVICE

## Purpose
- Govern deterministic, read-only knowledge retrieval workflows for Obsidian vault operations.
- Keep all runtime-boundary changes routed through central governance contracts.

## Primary User
- Governance operators and maintainers for `obsidian-mcp`.

## Boundaries
- In scope: governance contracts, allowlist policy, evidence/trace-linked validation.
- Out of scope: runtime MCP implementation in `ai-governance`.

## Dependencies
- `control/registry/services.v0.1.json`
- `control/registry/mcps.v0.1.json`
- `schemas/bridge_intent.schema.json`
- `schemas/mcp_change_request.schema.json`
- `scripts/validate_all.sh`

## Owner
- Team: Platform Operations
- Contact: platform-ops-owner
