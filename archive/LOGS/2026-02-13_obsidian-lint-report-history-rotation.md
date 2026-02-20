- Date: 2026-02-13
- Project: ai-governance
- Type: feature
- Tags: obsidian, lint, history
- Summary (1 line): Added timestamped archive rotation for Obsidian lint reports on each sync run.

## What changed

- Updated `scripts/obsidian_rag_sync.sh` to copy latest lint report into `.ops/obsidian_tag_lint_reports/lint_<timestamp>.md`.
- Added env defaults in `.env.example`:
  - `OBSIDIAN_TAG_LINT_SYNC_REPORT`
  - `OBSIDIAN_TAG_LINT_HISTORY_DIR`
- Updated runbook `docs/37_OBSIDIAN_MCP_RAG_INTEGRATION.md`.

## Validation

- Ran `obsidian_rag_sync.sh sync` with strict mode.
- Confirmed history file creation under `.ops/obsidian_tag_lint_reports/`.
- `bash scripts/sync_hub_guard.sh ci` passes.
