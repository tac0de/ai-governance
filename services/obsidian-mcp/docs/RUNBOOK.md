# RUNBOOK

## Deploy
- Run governance checks:
  - `bash scripts/validate_all.sh`
  - `bash scripts/test_determinism.sh`
- Run bridge dry-run:
  - `bash scripts/bridge_one_shot_local.sh obsidian-mcp.readflow.v1 traces/local/pm_objective_tdp_phase1_simple_loop.txt medium true architect-owner`
- Export long-lived governance traces from `traces/` into the external Obsidian runtime after validation.

## Rollback
- Revert latest obsidian-mcp governance export contract changes.
- Re-run validation and determinism checks.

## Incident Steps
- Detect: schema failure, determinism mismatch, missing trace/evidence refs.
- Contain: freeze rollout and disable non-essential policy updates.
- Recover: restore last compliant contract set.
- Verify: all governance scripts pass with trace linkage restored.

## Access and Key Revocation
- Rotate credentials when boundary violations are detected.
- Record revocation and rationale in external Obsidian governance diary artifacts.
