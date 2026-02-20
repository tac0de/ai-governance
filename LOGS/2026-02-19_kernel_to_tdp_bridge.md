# 2026-02-19 — kernel-engine to thedivineparadox bridge

## Summary
- Added kernel bridge path in `thedivineparadox` backend.
- Flow now attempts: game action -> kernel command execute -> response attach (`kernel` field).

## Implementation
- `apps/backend/src/kernelBridge.ts`
- `apps/backend/src/index.ts`
- `apps/backend/src/types.ts`

## Runtime behavior
- If `@kernel/core` module is available, bridge returns `mode=kernel` with `trace_id`.
- If unavailable, bridge fails safe with `mode=fallback` and game loop continues.

## Evidence
- Local API response includes:
  - `kernel.connected`
  - `kernel.mode`
  - optional `kernel.trace_id`
