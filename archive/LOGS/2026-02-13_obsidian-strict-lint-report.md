- Date: 2026-02-13
- Project: ai-governance
- Type: feature
- Tags: obsidian, lint, reporting
- Summary (1 line): Added automatic strict lint summary report file for each Obsidian sync run.

## What changed

- Extended `scripts/lint_obsidian_tags.sh` with optional `report_file` output.
- Updated `scripts/obsidian_rag_sync.sh` to write `.ops/obsidian_tag_lint_report.md` on each sync.
- Updated `docs/37_OBSIDIAN_MCP_RAG_INTEGRATION.md` to document default report path.

## Validation

- Strict violation case writes report with violation entries.
- Strict pass case writes report with checked file count and zero violations.
- `bash scripts/sync_hub_guard.sh ci` passes.
