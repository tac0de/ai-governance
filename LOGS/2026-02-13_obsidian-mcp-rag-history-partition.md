- Date: 2026-02-13
- Project: ai-governance
- Type: feature
- Tags: obsidian, mcp, rag, history
- Summary (1 line): Added Obsidian MCP bridge, incremental Obsidian-to-RAG sync, remote mirror sync, and sensitive-history partition pipeline.

## What changed

- Added `mcp/obsidian-mcp` (tools: `vault_list`, `note_read`, `notes_changed`, `source_list_build`).
- Added `scripts/obsidian_rag_sync.sh` for baseline-forward incremental classification and pack generation.
- Added `scripts/obsidian_remote_sync.sh` for private git mirror push.
- Added `scripts/history_partition.sh` to split new history into `active` vs `dump_sensitive`.
- Added runbooks: `docs/37_OBSIDIAN_MCP_RAG_INTEGRATION.md`, `docs/38_HISTORY_PARTITION_POLICY.md`.

## Validation

- `bash -n scripts/obsidian_rag_sync.sh`
- `bash -n scripts/obsidian_remote_sync.sh`
- `bash -n scripts/history_partition.sh`
- `node --check mcp/obsidian-mcp/src/server.js`
- `bash scripts/sync_hub_guard.sh ci`
