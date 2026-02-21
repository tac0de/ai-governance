# AI Governance Roles v1

## Purpose
Define a fixed role model for ai-governance using two layers:
- Internal Government Layer (human-society metaphor)
- External Enterprise Layer (delivery metaphor)

This model is normative and is used for policy enforcement and audit interpretation.

## Constitutional Boundary
- Internal governance operates under AI Government principles.
- External execution and delivery operate under AI Enterprise principles.
- This boundary is mandatory and cannot be bypassed by runtime workflows.

## Human Sovereignty and AI Status
- AI is not a subject of rights; it is an automated control mechanism defined by humans.
- Risk control is enforced by pre-defined rules, not autonomous AI discretion.
- Final sovereignty always belongs to humans; AI only executes human intent consistently.

## Charter Version Tag
- `ROLES_CHARTER_VERSION=v1`
- `ROLE_CLOSURE_STATUS=locked`

## Technology Neutrality
- The role model is protocol-agnostic and implementation-agnostic.
- MCP is an optional integration mechanism, not a governance role.
- No policy or audit decision may depend on a specific protocol name.
- Operational protocol requirements are defined outside this charter by contract/policy documents.

## Fixed Role Set

### Internal Government Layer (Human Society Metaphor)

#### 1) Strategy Board (Legislative Analogy)
- Owns constitutional intent and long-term direction.
- Approves structural boundaries.
- Cannot execute runtime actions directly.

#### 2) Policy Office (Executive Policy Analogy)
- Converts constitutional intent into enforceable policy.
- Owns allowlist/denylist and guardrails.
- Can reject plans before execution.

#### 3) Audit Core (Judicial/Inspector Analogy)
- Owns deterministic integrity verification.
- Produces PASS/REJECT with fixed reason codes.
- Cannot execute business delivery actions.

### External Enterprise Layer (Exactly Four Roles)

#### 4) CEO (Strategy Owner)
- Co-owned role between Human CEO and AI CEO.
- Final sovereignty and final approval always belong to Human CEO.
- AI CEO may propose and co-steer, but cannot override human final decision.

#### 5) CTO (Execution Integrity Owner)
- Owns execution integrity and technical closure.
- Owns runtime execution orchestration responsibility.
- Must obey government-layer policy and audit outcomes.

#### 6) Head of Product (Market Fit Owner)
- Owns product direction and user-value hypotheses.
- Cannot bypass policy, audit, or boundary rules.

#### 7) Head of Revenue (Distribution Owner)
- Owns growth/distribution/revenue operations.
- Cannot override governance boundary or compliance constraints.

## Separation of Duties
- Planning, execution, and audit must remain separate.
- No single role can self-authorize and self-audit the same action.
- Role conflicts must be recorded in decision-log before rollout.

## Expansion Freeze
- No additional roles are allowed unless explicitly approved by System Architect.
- Department-style role expansion is frozen in v1.
