# ADR-0005: Bootstrap Plan for thedivineparadox Repository v1

## Status
Accepted

## Date
2026-02-20

## Context
`thedivineparadox` will be operated as an experimental product site with local-first validation and staged cloud deployment.
`ai-governance` must remain the governance/control plane and must not absorb product runtime code.

## Decision
Adopt a separate-repository bootstrap plan for `thedivineparadox` with fixed initial structure, role hand-off, and gate alignment.

### Bootstrap Scope (v1)
1. Create a separate local repository and remote repository.
2. Initialize minimum structure:
   - `app/`
   - `infra/`
   - `scripts/`
   - `.github/workflows/`
   - `docs/`
3. Define deployment path in `infra/` for `local -> staging -> production`.
4. Configure OpenAI/GCP secrets and budget defaults in repo-level settings.
5. Bind initial workflow gates to governance checks before first production deploy.

### Non-Goals (v1)
- No migration of governance runtime into the product repo.
- No bypass of release/safety gates for first production deploy.

## Role Hand-off
- Architect: provides product intent and boundary constraints.
- Product/Domain owner: defines feature backlog.
- ControlPlaneOperator: sets pipelines and deploy mechanics.
- Policy owner: verifies gate compliance.
- Audit owner: verifies evidence and incident linkage.

## Gate Alignment Requirements
Before first production deploy, all must be true:
1. `ROLES_CHARTER_VERSION` gate is aligned.
2. `OPM_VERSION` gate is aligned.
3. Secrets tier gate is passing.
4. Incident template linkage exists for failure paths.
5. Done Gate criteria are explicitly marked `DONE`.

## Consequences
- Positive: product iteration speed and governance stability can scale independently.
- Positive: failure analysis remains deterministic through shared governance contract.
- Constraint: cross-repo changes require explicit mapping from product workflow to governance gate.

## Linked Documents
- `constitution/charter/THE_DIVINE_PARADOX_ONBOARDING_V1.md`
- `constitution/policies/OPERATING_PROFILE_MATRIX_V1.md`
- `constitution/policies/DONE_GATE_POLICY_V1.md`

## Follow-up
- Create a concrete bootstrap checklist artifact once first product idea is provided.
- Add product-workflow to governance-gate mapping table in a dedicated contract file.
