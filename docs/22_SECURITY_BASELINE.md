# Security Baseline (Minimal)

## Goal
Prevent accidental secret exposure with low operational overhead.

## Rules
1. Keep secrets in local env files only (`.env`, `.env.local`).
2. Never commit `.env` files or raw credentials.
3. Rotate credentials immediately after suspected exposure.
4. Use separate credentials per service and per environment (`dev`, `prod`).

## Required checks in ai-governance
- Before push: `bash tools/repo_sweep.sh --strict`
- Before merge handoff: `bash tools/main_hub_final_check.sh`
- Optional admin governance audit: `node tools/openai_admin_audit.js --strict`

## Rotation priority
1. OpenAI API keys
2. Admin dashboard and webhook tokens
3. Cloud provider service credentials
4. Any third-party access token in runtime env

## Incident response (light mode)
1. Disable leaked key.
2. Issue a replacement key.
3. Update runtime env and redeploy.
4. Re-scan repository.
5. Review logs and usage anomalies.

## Notes
- `ai-governance` is governance-only; runtime secret scanning execution belongs to runtime repositories.
- Authority remains in infrastructure and IAM, not in model behavior.
