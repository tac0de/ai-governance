- Date: 2026-02-13
- Project: ai-governance
- Type: feature
- Tags: firebase, gcp, checklist
- Summary (1 line): Pushed Firebase auth/progress endpoint to codex-engine and added local GCP integration checklist generator.

## What changed

- codex-engine remote push:
  - `netlify/functions/_lib/firebaseAuth.ts`
  - `netlify/functions/progress.ts`
  - README update for Firebase env/runtime use
- ai-governance additions:
  - `scripts/gcp_service_checklist.sh`
  - `docs/41_GCP_SERVICE_CHECKLIST.md`
  - `README.md` link update

## Validation

- `cd ../codex-engine && npm run typecheck --silent`
- `bash scripts/gcp_service_checklist.sh .ops`
- `bash scripts/sync_hub_guard.sh ci`
