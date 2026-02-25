# Council Under Siege Governance Progress 2026-02-25 (v0.2)

## Scope
- Execute the approved 3-track full cycle:
  - `ai-governance` integrity hardening
  - `obsidian-mcp` public runtime bootstrap
  - `council-under-siege` contract-hook runtime integration

## Completed
1. Governance hash-policy closure:
- Added raw-file hash helper:
  - `scripts/hash_file.sh`
- Enforced evidence hash validation in central gate:
  - `scripts/validate_all.sh`
  - `mcp-request` now fails if `evidence_refs.path` is missing or `sha256` mismatches.

2. Naming baseline and governance artifact refresh:
- Standardized council-facing reports to `council-under-siege` naming.
- Added new high-tier MCP registration request artifact:
  - `reports/governance/mcp-request-council-under-siege-core-knowledge-vault-mcp-20260225.json`
  - `request_type=new_mcp_registration`
  - `approval_tier=high`, `risk_tier=high`, `human_gate_required=true`, `status=requested`

3. Evidence hash synchronization:
- Recomputed raw-file SHA-256 values for all:
  - `reports/governance/mcp-request-*.json`
- Verified zero hash drift after sync.

4. Runtime-side contract hook implementation:
- Runtime repo:
  - `/Users/wonyoung_choi/projects/council-under-siege`
- Added contract hook module:
  - `/Users/wonyoung_choi/projects/council-under-siege/src/storeEventContract.ts`
- Integrated hooks into game runtime with default-off feature flag:
  - `/Users/wonyoung_choi/projects/council-under-siege/src/main.ts`
- Fixed runtime package naming:
  - `/Users/wonyoung_choi/projects/council-under-siege/package.json` -> `name: council-under-siege`

## Validation Results
- Governance:
  - `bash scripts/validate_all.sh` => `VALIDATION_PASS`
  - `bash scripts/test_determinism.sh` => `DETERMINISM_PASS`
- Negative test:
  - Tampered one `evidence_refs.sha256` -> `validate_all.sh` failed as expected.
  - Restored original file and re-ran gate => `VALIDATION_PASS`.
- Runtime:
  - `cd /Users/wonyoung_choi/projects/council-under-siege && npm run build` => pass

## Guardrail Status
- No pre-approval updates were applied to:
  - `control/registry/mcps.v0.1.json`
  - `mcps/*/manifest.json`
  - `services/*/mcp.allowlist.json`
- High-tier MCP registration request remains `status=requested`.
