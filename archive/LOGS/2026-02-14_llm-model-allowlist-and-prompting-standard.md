- Date: 2026-02-14
- Project: ai-governance
- Type: policy
- Tags: openai, model-policy, prompting
- Summary (1 line): Added an explicit OpenAI model allowlist (max 3) and a single prompting standard doc aligned to official guidance.

## What changed

- Added `docs/45_LLM_MODEL_SET_AND_PROMPTING_STANDARD.md` (official links + canonical prompt template).
- Added `OPENAI_ALLOWED_MODELS` to `.env.example`.
- Enforced allowlist in `scripts/autonomy_99_loop.sh` when `OPENAI_REAL_CALL=true`.
- Documented allowlist in `docs/26_PLATFORM_AUTONOMY_99.md`.
- Linked the doc from `README.md` and `MASTER_CONTEXT.md`.

## Notes

- This does not change the default cost policy (`OPENAI_REAL_CALL=false` remains the default).

## Validation

- `bash -n scripts/autonomy_99_loop.sh`
- `bash scripts/sync_hub_guard.sh ci`
