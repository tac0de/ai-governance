- Date: 2026-02-13
- Project: ai-governance
- Type: feature
- Tags: obsidian, rag, classification
- Summary (1 line): Upgraded Obsidian classification to prioritize frontmatter/tags before keyword fallback.

## What changed

- Updated `scripts/obsidian_rag_sync.sh` classification logic.
- Updated `mcp/obsidian-mcp/src/server.js` classification logic.
- Updated runbook `docs/37_OBSIDIAN_MCP_RAG_INTEGRATION.md` with explicit policy.

## Validation

- `bash -n scripts/obsidian_rag_sync.sh`
- `node --check mcp/obsidian-mcp/src/server.js`
- Sample vault test: `public/private/dump` tagged notes were routed correctly.
