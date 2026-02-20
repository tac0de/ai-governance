- Date: 2026-02-13
- Project: ai-governance
- Type: feature
- Tags: obsidian, lint, strict-mode
- Summary (1 line): Added strict mode to Obsidian tag lint for path-scoped required bucket tags.

## What changed

- Extended `scripts/lint_obsidian_tags.sh` with strict mode env flags:
  - `OBSIDIAN_TAG_STRICT=true`
  - `OBSIDIAN_TAG_REQUIRED_PATHS="<prefix1,prefix2>"`
- Updated `docs/37_OBSIDIAN_MCP_RAG_INTEGRATION.md` with strict mode usage.

## Validation

- Strict mode fails when a matched-path note has no bucket tag.
- Strict mode passes after adding one bucket tag (`public/private/dump`).
