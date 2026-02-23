# TheDivineParadox Strategy Council v0.1

## Purpose
Provide a single governance forum for service concept direction, macro product choices, and release-level prioritization.

## Scope
- In scope:
  - Product concept clarity
  - Release priorities and sequencing
  - KPI definition and success thresholds
  - Risk acceptance for high-tier decisions
- Out of scope:
  - Runtime implementation details
  - UI pixel-level edits
  - Ad-hoc feature requests without evidence

## Council Structure
- Chair: Architect Owner (final tie-break authority)
- Product Lead: Strategy/PM owner
- Engineering Lead: Backend owner
- Experience Lead: UI/UX owner
- Governance Observer: policy compliance owner

## Cadence
- Weekly decision review (fixed 45 minutes)
- Emergency review only for `high` approval tier changes

## Required Inputs Per Session
- Current objective statement (single sentence)
- Decision candidates (max 3)
- Evidence pack:
  - latest trace/result summary
  - KPI trend snapshot
  - risk notes
- Explicit constraints list

## Decision Output Contract
Every approved decision must emit:
- `decision_id`
- `owner`
- `deadline_utc`
- `approval_tier`
- `expected_kpi_impact`
- `rollback_condition`
- `evidence_refs`

Store outputs under `reports/governance/` with deterministic timestamps.

## Priority Model
- P0: Breaks determinism, traceability, or fallback guarantees
- P1: Blocks launch-critical user path
- P2: Improves conversion, trust, or UX quality gate pass rate
- P3: Nice-to-have optimization

## KPI Baseline (v0.1)
- Vote completion rate
- First meaningful interaction time
- Daily return participation
- LLM degraded-rate
- UI quality gate pass-rate

## Governance Gates
- `medium`: policy review + owner approval + acceptance pass
- `high`: architect sign-off mandatory
- Production deployment remains human-gated

## Working Rules
- Keep one primary objective per cycle.
- Limit active initiatives to top 2 priorities.
- No new initiative without an owner and rollback condition.
- If evidence is missing, decision is deferred.

## Versioning
- This document is frozen for `v0.1`.
- Changes require change-management review and explicit version bump.
