- Date: 2026-02-13
- Project: ai-governance
- Type: feature
- Tags: obsidian, lint, policy
- Summary (1 line): Added `.env` policy default loading for Obsidian tag lint and documented default keys.

## What changed

- Updated `scripts/lint_obsidian_tags.sh` to load `.env` when present.
- Added `OBSIDIAN_TAG_STRICT` and `OBSIDIAN_TAG_REQUIRED_PATHS` to `.env.example`.
- Updated `docs/37_OBSIDIAN_MCP_RAG_INTEGRATION.md` with `.env`-based default enforcement note.

## Validation

- `bash -n scripts/lint_obsidian_tags.sh`
- `bash scripts/sync_hub_guard.sh ci`
