# Agent-Collab Webgame Governance Progress 2026-02-25

## Scope
- Implement v0.2 decision-complete governance onboarding plan inside `ai-governance` only.

## Completed
1. Registered new service contract package:
- `services/council-under-siege/*`
- Added fixed docs set under `services/council-under-siege/docs/`

2. Synced central registries:
- `control/registry/services.v0.1.json`
- `control/registry/org.v0.1.json`

3. Added Phase 1 objective + intent artifacts:
- `tmp/pm_objective_council_under_siege_phase1.txt`
- `tmp/council-under-siege.phase1.intent.local.json`

4. Added MCP change requests (capability expansion):
- `reports/governance/mcp-request-council-under-siege-analytics-turn-consensus-20260225.json`
- `reports/governance/mcp-request-council-under-siege-safety-turn-guard-20260225.json`

5. Ran bridge dry-runs:
- `bridge_local_pm.sh` (medium, human gate false)
- `bridge_one_shot_local.sh` (medium, human gate false)
- human-gate path check (`medium + true` -> `bridge_human_gate.sh approve` -> dispatch/consume)

## Validation Results
- `bash scripts/validate_all.sh` => `VALIDATION_PASS`
- `bash scripts/test_determinism.sh` => `DETERMINISM_PASS`

## Notes
- New capability requests remain `status=requested`.
- Per plan, no pre-approval updates were made to:
  - `control/registry/mcps.v0.1.json`
  - `mcps/*/manifest.json`
  - requested new capabilities in service allowlist
