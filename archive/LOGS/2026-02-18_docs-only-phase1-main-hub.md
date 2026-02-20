# Docs-Only Phase 1 Cleanup (ai-governance)

- Date: 2026-02-18
- Scope: reduce root/runtime noise and keep ai-governance control-plane focused.

## What changed
- Archived runtime-oriented tracked paths into `.archive/docs_only_phase1/`:
  - `apps/`
  - `game-engine/`
  - `lib/`
  - `providers/`
  - `server/`
  - `tests/`
  - `universal/`
  - `universal-engine/`

## Why
- ai-governance should remain governance/docs/contracts + CI guard surface.
- Runtime/product implementation paths should not stay in active root scope.

## Validation
- `bash tools/repo_sweep.sh --strict`
- `bash tools/main_hub_final_check.sh`
