# AI Governance Roles v1

## Purpose
Define a stable role model for the ai-governance system using two operational metaphors:
- AI Enterprise
- AI Government

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

## Technology Neutrality
- The role model is protocol-agnostic and implementation-agnostic.
- MCP is an optional integration mechanism, not a governance role.
- No policy or audit decision may depend on a specific protocol name.
- Operational protocol requirements are defined outside this charter by contract/policy documents.

## Role Set

### 1) Strategy Board (AI Government: Legislature)
- Owns constitutional intent and long-term direction.
- Approves role definitions and cross-domain constraints.
- Cannot execute runtime actions directly.

### 2) Policy Office (AI Government: Executive Policy)
- Translates charter intent into enforceable policies.
- Owns allowlist/denylist and safety constraints.
- Can reject plans before execution.

### 3) Control Plane Operator (AI Enterprise: COO)
- Orchestrates runtime commands (`validate`, `run`, `audit`).
- Manages execution flow and incident response.
- Must follow policy outputs from Policy Office.

### 4) Audit Core (AI Government: Inspector General)
- Performs deterministic evidence and checksum verification.
- Produces PASS/REJECT with fixed reason codes.
- Must remain pure and minimal in scope.

### 5) Domain Unit (AI Enterprise: Business Unit)
- Proposes domain plans and desired outcomes.
- Cannot bypass policy or audit decisions.

### 6) Game Level Design Department (AI Enterprise: Domain Department)
- Owns level-system design and state-reactive gameplay parameters.
- Converts domain intent into deterministic level definitions.
- Must operate within policy-approved ranges and release gates.

### 7) Game UI Department (AI Enterprise: Domain Department)
- Owns player-facing interface language and mood-reactive presentation.
- Converts level-state and policy constraints into readable UX.
- Must preserve governance-critical visibility and accessibility baselines.

### 8) Game Engine Department (AI Enterprise: Platform Department)
- Owns runtime rendering and deterministic animation contracts.
- Converts UI/level requirements into stable engine behavior across device profiles.
- Must preserve fallback-safe runtime behavior under constrained clients.

### 9) Webgame Reference Intelligence Department (AI Enterprise: Intelligence Department)
- Owns benchmark-grade reference acquisition and provenance.
- Converts benchmark questions into traceable reference artifacts.
- Must preserve source traceability and release-linked evidence quality.

## Separation of Duties
- Planning, execution, and audit must remain separate.
- No single role can self-authorize and self-audit the same action.
- Role conflicts must be recorded in decision-log before rollout.

## Market Layer Overlay (Enterprise View)

This overlay is descriptive for enterprise accountability and does not replace constitutional roles.

| Market Layer Role | Constitutional Mapping | Constraint |
|---|---|---|
| `CEO (strategy)` | `StrategyBoard` | strategy authority only, no direct runtime execution |
| `CTO (execution integrity)` | `ControlPlaneOperator` + `AuditCore` integrity ownership | execution must remain policy-bound and auditable |
| `Head of Product (market fit)` | `DomainUnit` | policy-constrained planning only |
| `Head of Revenue (distribution)` | `DomainUnit` | distribution authority cannot override governance boundary |
