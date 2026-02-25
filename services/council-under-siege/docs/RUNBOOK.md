# RUNBOOK

## Routine Validation
- `bash scripts/validate_all.sh`
- `bash scripts/test_determinism.sh`

## Bridge Execution
- Create objective text under `tmp/`.
- Generate and submit intent:
  - `bash scripts/bridge_local_pm.sh <intent_id> <objective_file> <intent_out_json> medium false --auto`
- For human-gated runs:
  - `bash scripts/bridge_human_gate.sh <intent_id> approve <actor>`
  - `bash scripts/bridge_dispatch.sh`
  - `bash scripts/bridge_consume.sh`

## Incident Handling
- If determinism fails, halt rollout and capture evidence refs.
- If schema validation fails, reject change and patch contract artifacts.
- Record remediation in governance progress report.
