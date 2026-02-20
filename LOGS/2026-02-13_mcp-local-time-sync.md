- Date: 2026-02-13
- Project: ai-governance
- Type: feature
- Tags: mcp, time-sync, workflow-mcp
- Summary (1 line): Added local_time_now MCP tool to provide local machine time with timezone metadata for ChatGPT sync.

## What changed

- Added `local_time_now` tool in `mcp/workflow-mcp/src/server.js`.
- Updated MCP docs in `mcp/workflow-mcp/README.md`, `README.md`, and `docs/25_PLATFORM_SEMI_AUTOMATION_94.md`.

## Validation

- Ran `npm run check` in `mcp/workflow-mcp`.
- Ran MCP smoke test and confirmed `local_time_now` is listed and returns local time payload.
