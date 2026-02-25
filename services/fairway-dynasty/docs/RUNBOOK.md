# RUNBOOK

## Deploy
- Run governance checks:
  - `bash scripts/validate_all.sh`
  - `bash scripts/test_determinism.sh`
- Run bridge one-shot dry-run:
  - `bash scripts/bridge_one_shot_local.sh fairway-dynasty.phase1.operations_loop tmp/pm_objective_fairway_dynasty_phase1.txt medium true architect-owner`

## Rollback
- Revert latest service contract change set.
- Re-run validation + determinism checks.

## Incident Steps
- Detect: schema failure, determinism mismatch, missing trace/evidence refs.
- Contain: freeze rollout and disable non-essential paths.
- Recover: restore last compliant contract set.
- Verify: all governance scripts pass with trace linkage restored.

## Access and Key Revocation
- Rotate credentials when policy breach involves external API boundaries.
- Record revocation and rationale in governance progress report.
