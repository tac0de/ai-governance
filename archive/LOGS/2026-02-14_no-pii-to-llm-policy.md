- Date: 2026-02-14
- Project: ai-governance
- Type: policy
- Tags: privacy, pii, llm
- Summary (1 line): Adopted a strict No-PII-to-LLM boundary across all providers and added a best-effort PII guard script.

## What changed

- Added `scripts/pii_guard.sh` (block/warn modes; no matched-content output).
- Added `PII_GUARD_ENABLED` / `PII_GUARD_MODE` to `.env.example`.
- Enforced `PII_GUARD_ENABLED=true` when `OPENAI_REAL_CALL=true` in `scripts/autonomy_99_loop.sh`.
- Updated `MASTER_CONTEXT.md`, `docs/26_PLATFORM_AUTONOMY_99.md`, and `docs/45_LLM_MODEL_SET_AND_PROMPTING_STANDARD.md`.

## Validation

- `bash -n scripts/autonomy_99_loop.sh`
- `bash -n scripts/pii_guard.sh`
- `bash scripts/sync_hub_guard.sh ci`
