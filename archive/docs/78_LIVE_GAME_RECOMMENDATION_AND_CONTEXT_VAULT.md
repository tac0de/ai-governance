# 78. Live Game Upgrade Recommendation + Context Vault

## Recommended game direction (single path)

Use a **12-turn Divine Trial Run** structure.

Core loop per turn:
1. Player chooses one divine gift.
2. Cost is computed (AI + deterministic guard).
3. World state shifts.
4. Event text updates and next turn starts.

Run structure:
- Turn 1-3: early pressure tutorial
- Turn 4-8: branching tension and compounding tradeoffs
- Turn 9-11: high-cost escalation
- Turn 12: judgment turn (ending)

Why this path:
- Keeps your existing architecture intact.
- Adds real replayability quickly.
- Makes content production manageable.

## Context Vault for ChatGPT continuity

Purpose:
- Keep short, reusable memory across sessions without polluting runtime code.

Storage model:
- append-only JSONL entries
- one file per day in `.ops/context_vault/YYYY-MM-DD.jsonl`
- schema-governed records (`contracts/context_vault_entry.schema.json`)
- optional hash chain fields for integrity (`prev_hash`, `record_hash`)

Entry quality rule:
- one entry = one decision or one lesson
- summary first, details optional
- include tags and related file paths

Minimal API shape (local tool level):
- `append`: add one memory entry
- `recent`: get latest N entries

## Phase order

Phase 1:
- Keep current game backend/frontend.
- Add 12-turn run framing and endings.
- Start recording operator + agent decisions into Context Vault.

Phase 2:
- Add scene packs (JSON content only).
- Add run-level metrics (completion rate, average cost, ending distribution).

Phase 3:
- Add recommendation prompts driven by Context Vault summaries.
