# TDP Experiment Orchestrator MCP

Purpose: controlled experiment routing with deterministic assignment and rollback controls.

Scope:
- Cohort assignment by deterministic key.
- Feature flag resolution with explicit version refs.
- Emergency kill-switch for unsafe experiments.

Out of scope:
- UI rendering logic.
- Unlogged ad-hoc experiment overrides.
