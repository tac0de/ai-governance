## Repo responsibilities
- ai-governance: governance, policies, versioned contracts, shared docs; no runtime code.
- engine: executes platform logic, adapters, orchestration, storage integrations.
- apps: user-facing products that call into engine APIs/SDKs.

## Dependency direction
- ai-governance ➜ engine ➜ apps.
- Policies and contracts flow down; runtime changes do not flow up without PRs updating contracts.

## Naming policy
- Legacy aliases are read-only references; all new naming uses `kernel-*` and `kernel/*`.

## Active derived repositories
- kernel-engine
  - local: `/Users/wonyoung_choi/kernel-engine`
  - remote: `https://github.com/tac0de/kernel-engine`
  - status: bootstrap restored with DTP contracts and core package scaffold
  - owner hub: `ai-governance` (contracts/policy source-of-truth)
- thedivineparadox
  - local: `/Users/wonyoung_choi/thedivineparadox`
  - remote: `https://github.com/tac0de/thedivineparadox`
  - status: v0.1 bootstrap shipped (backend/frontend/cloud run/domain mapping in progress)
  - owner hub: `ai-governance` (this repo is governance/source-of-truth)

## One-folder workspace view
- workspace root: `/Users/wonyoung_choi/_workspace`
- links:
  - `/Users/wonyoung_choi/_workspace/ai-governance`
  - `/Users/wonyoung_choi/_workspace/kernel-engine`
  - `/Users/wonyoung_choi/_workspace/thedivineparadox`
  - `/Users/wonyoung_choi/_workspace/personal-art-gallery`
  - `/Users/wonyoung_choi/_workspace/ai-constitution`
