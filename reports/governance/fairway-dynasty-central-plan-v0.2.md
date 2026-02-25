# Fairway Dynasty 2D Production Plan v0.2

Date: 2026-02-25
Mode: Governance-first, 72-hour cycle

## Locked Decisions
- 2D runtime with stylized painterly assets
- Operations-first core loop
- Gold + Prestige soft economy only
- 8-hour capped idle
- 3-step interactive tutorial (first-run mandatory, replay optional)
- localStorage snapshot + checksum integrity
- account-fixed base seed + day/action mixing

## Scope
- Central governance artifacts and validation path
- Fairway runtime loop: Initial -> Tutorial -> Operations -> Result -> Idle Return
- local-image-lab asset generation, manifest evidence, and import

## Out of Scope
- Real payment
- backend persistence
- new core MCP registration

## Validation Gate
- `bash scripts/validate_all.sh`
- `bash scripts/test_determinism.sh`
- `bash scripts/bridge_one_shot_local.sh fairway-dynasty.phase1.2d_loop tmp/pm_objective_fairway_dynasty_phase1_2d.txt medium true architect-owner`
