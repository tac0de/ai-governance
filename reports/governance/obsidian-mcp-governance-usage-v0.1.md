# Obsidian MCP Governance Usage v0.1

## Decision
- Obsidian MCP runtime stays outside this repo; `ai-governance` stores contracts and validation only.
- Cross-repo linking via `governed-services` is deprecated and optional.
- Runtime remains in `/Users/wonyoung_choi/projects/obsidian-mcp`; `ai-governance` stores contracts and validation only.

## Why This Helps Governance
- Converts note retrieval and evidence lookup into trace-linked, policy-bounded execution units.
- Enables deterministic replay for governance decisions that use knowledge vault context.
- Keeps high-tier boundary review explicit when enabling write-capable tools.

## Recommended Usage Pattern
1. Use Obsidian MCP as a read-only evidence source in planning and incident reviews.
2. Record every retrieval action via bridge intent and evidence refs.
3. Restrict tool scope to listing, reading, searching, and metadata retrieval.
4. Escalate any write/delete capability request as high-tier change.

## Immediate Operating Loop
- Submit intent with objective and constraints.
- Attach vault evidence refs and hash checks.
- Run `bash scripts/validate_all.sh` and determinism checks.
- Publish final report in 1-4 governance format.
