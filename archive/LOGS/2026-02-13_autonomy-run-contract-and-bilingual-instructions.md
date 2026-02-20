- Date: 2026-02-13
- Project: ai-governance
- Type: feature
- Tags: workflow, run-contract, documentation
- Summary (1 line): Added run-contract enforcement to autonomy remote workflow and created bilingual human instructions.

## What changed

- Updated `.github/workflows/autonomy-99-remote.yml` to create/validate/upload `.ops/run_contract.json`.
- Added `docs/35_HUMAN_INSTRUCTIONS_BILINGUAL.md` (Korean + English operator guide).
- Updated `README.md`, `MASTER_CONTEXT.md`, and `DECISIONS.md` for consistency.

## Validation

- `bash scripts/validate_run_contract.sh --file /tmp/run_contract_ok.json` passed.
- `bash scripts/sync_hub_guard.sh ci` passed.
