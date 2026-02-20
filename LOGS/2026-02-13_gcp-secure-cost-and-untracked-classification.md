- Date: 2026-02-13
- Project: ai-governance
- Type: feature
- Tags: gcp, security, cost, hygiene
- Summary (1 line): Added untracked-file classifier and GCP secure/cost automation script with manual prerequisite boundaries.

## What changed

- Added `scripts/classify_untracked.sh` and generated local classification report (`.ops/untracked_classification.md`).
- Added `scripts/gcp_secure_cost_setup.sh` (`status|apply|budget`) and runbook `docs/39_GCP_SECURE_COST_AUTOMATION.md`.
- Updated `.env.example` with GCP runtime/budget fields.
- Updated `.gitignore` to ignore generated/sensitive local artifacts.

## Validation

- `bash scripts/classify_untracked.sh`
- `bash -n scripts/gcp_secure_cost_setup.sh`
- Installed `gcloud-cli` via Homebrew (manual login/project selection still required).
- `bash scripts/sync_hub_guard.sh ci`
