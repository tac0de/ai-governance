# ADR-0002: v1 Delivery Track (Macro Execution Order)

## Status
Accepted

## Date
2026-02-20

## Context
v0 baseline is established:
- responsibility-based repository layout
- deterministic `validate/run/audit`
- role model documents for AI Enterprise / AI Government

A macro execution track is required to prevent fragmented local optimizations.

## Decision
Adopt the following v1 macro order:

1. Role-to-policy enforcement:
   - bind `actor_role` to policy evaluation and execution permission.
2. Contract hardening:
   - align plan/result/evidence/audit schemas with role-aware constraints.
3. Audit authority hardening:
   - make reject reasons deterministic under stable priority order.
4. Operational control gates:
   - enforce no-bypass path for validate -> run -> audit.
5. Release governance:
   - introduce role-gated release criteria for control-plane and audit-core.

## Consequences
- Positive: work stays architecture-first.
- Positive: implementation order is decision-complete for v1.
- Constraint: local refactors without macro milestone linkage are deprioritized.
