- Date: 2026-02-13
- Project: ai-governance
- Type: feature
- Tags: obsidian, lint, guardrail
- Summary (1 line): Added Obsidian tag conflict lint guard and enforced it in pre-commit and sync flow.

## What changed

- Added `scripts/lint_obsidian_tags.sh`.
- Updated `.githooks/pre-commit` to run `lint_obsidian_tags.sh repo`.
- Updated `scripts/obsidian_rag_sync.sh` to run `lint_obsidian_tags.sh vault <since_iso>` before classification.
- Updated runbook `docs/37_OBSIDIAN_MCP_RAG_INTEGRATION.md`.

## Validation

- Conflict case with `tags: [public, private]` fails as expected.
- Single-bucket tag note passes.
- `bash scripts/sync_hub_guard.sh ci` passes.
