- Date: 2026-02-12
- Project: ai-governance
- Type: implementation
- Tags: local-only, privacy, warp
- Summary (1 line): Added and applied local-only hardening command for Warp privacy settings.

Notes:

- Added `scripts/local_only_mode.sh` with `apply` and `status` commands.
- Enforced Warp cloud conversation storage, settings sync, telemetry, and crash reporting to OFF.
- Saved local-only status report at `.ops/local_only_mode_status.json`.
