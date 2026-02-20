- Date: 2026-02-13
- Project: ai-governance
- Type: feature
- Tags: orchestration, ci, policy
- Summary (1 line): Added run contract validation script and enforced it in security-baseline workflow.

## What changed

- Added `scripts/validate_run_contract.sh`.
- Updated `.github/workflows/security-baseline.yml` to create/validate/upload `.ops/run_contract.json`.
- Added quick command in `README.md`.

## Validation

- `bash -n scripts/validate_run_contract.sh`
- PASS case verified with valid sample JSON.
- FAIL case verified when `human_gate_required=true` and `approved_by` is empty.
