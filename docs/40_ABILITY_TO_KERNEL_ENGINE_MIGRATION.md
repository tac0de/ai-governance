# Ability -> Kernel-Engine Migration Runbook

## Objective
Migrate `ability-*` lineage into `kernel-engine` runtime workflows while preserving governance traceability.

## Boundary
- `ai-governance`: migration policy, decisions, and audit notes.
- `kernel-engine`: migration executors, runtime adapters, and rollout scripts.

## Migration intent
1. Sync source assets into `kernel-engine`.
2. Preserve inheritance points as report artifacts.
3. Expand from local-only storage to login + DB-backed persistence.

## Runtime execution ownership
All executable migration commands are owned by `kernel-engine` and are not executed in `ai-governance`.

## Rollout strategy
1. Keep local storage fallback pre-login.
2. On login, migrate local payload to DB.
3. Switch reads/writes to DB-backed repository for authenticated users.
4. Keep local-only mode for offline sessions.
