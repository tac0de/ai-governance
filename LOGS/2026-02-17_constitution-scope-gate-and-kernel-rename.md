- Date: 2026-02-17
- Project: ai-governance
- Type: implementation
- Tags: constitution, ci, naming, kernel
- Summary
  Added a CI gate to block runtime paths in ai-governance and renamed local plan/agent files from codex naming to kernel naming.

## Details
- Added `.github/workflows/constitution-scope-check.yml` to fail when runtime paths are modified in this repo.
- Renamed `plans/codex-engine-expansion.md` to `plans/kernel-engine-expansion.md`.
- Renamed `scripts/codex_engine_agent.sh` to `scripts/kernel_engine_agent.sh` and updated internal references.
