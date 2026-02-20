- Date: 2026-02-13
- Project: ai-governance
- Type: feature
- Tags: security, account-hardening, operations
- Summary (1 line): Added Top4 account security runbook and local progress tracker for Google/GitHub/Apple/ChatGPT.

## What changed

- Added `docs/36_TOP4_ACCOUNT_SECURITY_RUNBOOK.md`.
- Added `config/top4_security_baseline.example.json`.
- Added `scripts/top4_account_security.sh` (`init/status/next/done/links`).

## Validation

- `bash scripts/top4_account_security.sh init`
- `bash scripts/top4_account_security.sh status`
- `bash scripts/top4_account_security.sh next`
- `bash scripts/sync_hub_guard.sh ci`
