# Onboarding Playbook

## New Service Onboarding
1. Create `services/<service-id>/` using `control/templates/service`.
2. Register service in `control/registry/services.v0.1.json`.
3. Add `policy.profile.json` and `mcp.allowlist.json`.
4. Pass `scripts/validate_all.sh`.

## New MCP Onboarding
1. Create `mcps/<mcp-id>/` with manifest and docs.
2. Register MCP in `control/registry/mcps.v0.1.json`.
3. Map capabilities and approval tier.
4. Pass `scripts/validate_all.sh`.
