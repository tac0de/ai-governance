# Orchestration Change Discipline

## Objective
Reduce human error when changing governance, policy, and workflow files.

## Rule
When a commit includes orchestration-impacting files:
- `tools/`
- `config/`
- `.github/workflows/`
- `contracts/`
- `docs/`

The same commit should also stage:
- `MASTER_CONTEXT.md`
- one `LOGS/*.md` entry for significant operational changes

Additionally, if a commit includes:
- `tools/control_plane_guard.sh`
- any `.github/workflows/*`

It should also stage:
- `DECISIONS.md`

## Enforcement
- Local verification: `bash tools/control_plane_guard.sh <base_sha> <head_sha>`
- CI baseline checks: `.github/workflows/sync-hub-check.yml` and `.github/workflows/constitution-scope-check.yml`

## Notes
- Keep changes minimal.
- Use `UNKNOWN` explicitly when a fact is not confirmed.
