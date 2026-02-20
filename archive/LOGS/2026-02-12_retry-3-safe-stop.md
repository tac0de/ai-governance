- Date: 2026-02-12
- Project: ai-governance
- Type: implementation
- Tags: retry, safety-stop, human-gate
- Summary (1 line): Added 3-retry safety policy and automatic human-gate stop on repeated step failures.

Notes:

- Updated `scripts/autonomy_99_loop.sh` with per-step retry loop (`AUTONOMY_MAX_RETRIES=3` default).
- Added retry delay control (`AUTONOMY_RETRY_DELAY_SECONDS`).
- On repeated failure, loop now stops with `reason=step_failed_after_retries:<step>`.
