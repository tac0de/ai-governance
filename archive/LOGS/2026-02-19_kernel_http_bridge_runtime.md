# 2026-02-19 — Kernel HTTP bridge runtime stabilization

## What changed
- Added `kernel-engine-api` as standalone Cloud Run service.
- Removed local-only runtime coupling from `thedivineparadox` backend (`file:/Users/...` dependency path).
- Switched bridge logic to prefer HTTP call via `KERNEL_ENGINE_URL`.

## Live endpoints
- kernel engine api:
  - `https://kernel-engine-api-1028385057594.us-central1.run.app`
- thedivineparadox api:
  - `https://api.thedivineparadox.com`

## Verification
- `thedivineparadox` `/api/act` now returns:
  - `kernel.connected=true`
  - `kernel.mode=kernel`
  - `kernel.trace_id` present

## Operational effect
- Cloud Run runtime now reproduces kernel-bridge behavior without local filesystem dependency.
