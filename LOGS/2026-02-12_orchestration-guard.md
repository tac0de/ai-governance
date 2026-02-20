- Date: 2026-02-12
- Project: ai-governance
- Type: rules
- Tags: sync-hub, pre-commit, orchestration
- Summary (1 line): Added local guard to force context/decision/log updates on orchestration commits.

Notes:

- Added `scripts/sync_hub_guard.sh` for required structure and unsafe-rules checks.
- Wired `.githooks/pre-commit` to run the guard in `pre-commit` mode.
- Added orchestration commit-discipline checks for staged paths under scripts/config/workflows/mcp.
