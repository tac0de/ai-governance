# SERVICE

## Purpose
- Govern the external Obsidian operations hub that receives long-lived governance traces.
- Keep central diary/export flows deterministic and policy-bound.

## Primary User
- Architect-owner operating the external Obsidian governance hub.

## Boundaries
- In scope: export policy, trace retention contracts, evidence/trace-linked validation.
- Out of scope: runtime vault implementation in `ai-governance`.

## Dependencies
- `control/registry/services.v0.1.json`
- `control/registry/mcps.v0.1.json`
- `schemas/bridge_intent.schema.json`
- `schemas/mcp_change_request.schema.json`
- `scripts/validate_all.sh`

## Owner
- Team: Platform Operations
- Contact: architect-owner
