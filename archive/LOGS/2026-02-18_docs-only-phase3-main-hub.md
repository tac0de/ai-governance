# Docs-Only Phase 3 Cleanup (ai-governance)

- Date: 2026-02-18
- Scope: reduce one more root surface area by absorbing `plans/` into `docs/`.

## What changed
- Moved:
  - `plans/kernel-engine-expansion.md`
  - -> `docs/64_KERNEL_ENGINE_EXPANSION_PLAN.md`
- Removed now-empty root directory:
  - `plans/`
- Tightened guard/sweep scripts:
  - Removed `plans/` from `tools/control_plane_guard.sh` allowlist.
  - Removed `plans` from `tools/repo_sweep.sh` scan target list.

## Why
- Keep active root as docs/contracts/policy guard surface only.
- Avoid adding a separate planning root when docs already covers governance plans.

## Validation
- `bash tools/control_plane_guard.sh HEAD~1 HEAD`
- `bash tools/repo_sweep.sh --strict`
- `bash tools/main_hub_final_check.sh`
