# Obsidian MCP + RAG Integration Runbook

## Objective
Document governance boundary for Obsidian/RAG integrations.

## Current boundary
- `ai-governance` stores policy, naming, and safety guidance only.
- Runtime MCP implementation and sync executors are owned by `engine`.

## What remains in ai-governance
- policy references
- risk boundaries
- architecture decisions and migration records

## What is externalized
- Obsidian MCP runtime server
- incremental sync executors
- RAG packing runtime jobs

## Safety rule
No raw sensitive notes should cross hosted LLM boundaries without explicit sanitization and policy approval.

## Note
If execution commands are needed, run them from the runtime repository (`engine`) rather than `ai-governance`.
