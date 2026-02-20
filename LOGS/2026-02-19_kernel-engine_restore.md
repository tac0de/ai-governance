# 2026-02-19 — kernel-engine Restore

## Summary
- Restored `kernel-engine` as a standalone runtime repository.
- Imported DTP contracts from `ai-governance/contracts`.
- Added minimal core package scaffold (`@kernel/core`) for execution bootstrap.

## Locations
- local: `/Users/wonyoung_choi/kernel-engine`
- remote: `https://github.com/tac0de/kernel-engine`
- workspace shortcut: `/Users/wonyoung_choi/_workspace/kernel-engine`

## Bootstrap artifacts
- `contracts/*` copied from `ai-governance/contracts`
- `docs/70_DTP_PROTOCOL_PRINCIPLES.md`
- `docs/50_DTP_TRACE_REPLAY_2W_PILOT.md`
- `docs/71_ENGINE_TRACE_110_MAPPING_CHECKLIST.md`
- `packages/core/src/index.ts` minimal execute scaffold
- `tools/scripts/tac0de_demo.sh` trace demo output stub

## Governance
- `ai-governance/REPOS.md` updated to include restored `kernel-engine`.
