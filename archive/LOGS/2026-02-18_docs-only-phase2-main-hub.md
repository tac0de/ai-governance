# Docs-Only Phase 2 Cleanup (ai-governance)

- Date: 2026-02-18
- Scope: remove additional non-document root artifacts from active control-plane surface.

## What changed
- Archived root runtime metadata/tooling files into `.archive/docs_only_phase2/`:
  - `.archive/docs_only_phase2/root_metadata/package.json`
  - `.archive/docs_only_phase2/root_metadata/package-lock.json`
  - `.archive/docs_only_phase2/root_metadata/tsconfig.json`
  - `.archive/docs_only_phase2/bin/llm.mjs`
- Tightened control-plane guard allowlist in `tools/control_plane_guard.sh`:
  - Removed `bin/` from allowed roots
  - Removed root `package.json`, `package-lock.json`, `tsconfig.json` from allowed files

## Why
- Keep ai-governance visibly governance-first (docs/contracts/policy guards).
- Prevent re-growth of runtime/build metadata in root control-plane.

## Validation
- `bash tools/control_plane_guard.sh HEAD~1 HEAD`
- `bash tools/repo_sweep.sh --strict`
- `bash tools/main_hub_final_check.sh`
