# Fairway Dynasty Central Governance Plan v0.1

Date: 2026-02-25
Scope: governance-first restart for golf course operations tycoon webgame.

## Macro Gate
- Objective: deliver deterministic operations-loop prototype linked to central governance contracts.
- Scope: service onboarding artifacts, MCP request contract, bridge dry-run readiness.
- Forbidden: runtime implementation in governance core, unapproved capability expansion, real-payment path in Phase 1.
- Baseline risk: medium.
- Completion: contract package + request artifacts + validation pass.
- Rollback: any missing intent/policy/evidence/trace link, determinism mismatch, or missing human gate record.

## Phase-1 Constraints
- 2.5D frontend runtime only in service repo.
- Deterministic local simulation with seed-locked outputs.
- Mandatory bridge and append-only traces.

## Required Artifacts
- `tmp/pm_objective_fairway_dynasty_phase1.txt`
- `tmp/fairway-dynasty.phase1.intent.local.json`
- `reports/governance/mcp-request-fairway-dynasty-analytics-phase1-20260225.json`

## Validation
- `bash scripts/validate_all.sh`
- `bash scripts/test_determinism.sh`
- `bash scripts/bridge_one_shot_local.sh fairway-dynasty.phase1.operations_loop tmp/pm_objective_fairway_dynasty_phase1.txt medium true architect-owner`
