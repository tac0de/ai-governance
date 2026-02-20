- Date: 2026-02-13
- Project: ai-governance
- Type: feature
- Tags: migration, codex-engine, auth, database
- Summary (1 line): Added ability-to-codex-engine sync/extraction tooling and login+DB migration scaffold.

## What changed

- Added `scripts/sync_ability_to_codex_engine.sh` (status/sync/push with rename hint).
- Added `scripts/extract_ability_legacy_points.sh` to extract localStorage keys and inheritance points.
- Added runbook `docs/40_ABILITY_TO_CODEX_ENGINE_MIGRATION.md`.
- Added `codex-engine/` scaffold:
  - `db/schema.sql`
  - `src/storage/abilityRepository.ts`
  - `src/storage/dbRepository.example.ts`
  - `src/migration/localToDbMigration.ts`

## Validation

- `bash scripts/extract_ability_legacy_points.sh .ops`
- `bash scripts/sync_ability_to_codex_engine.sh status`
- `bash scripts/sync_hub_guard.sh ci`
