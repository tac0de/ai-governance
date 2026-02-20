# AI Governance Roles v1

## Purpose
Define a stable role model for the ai-governance system using two operational metaphors:
- AI Enterprise
- AI Government

This model is normative and is used for policy enforcement and audit interpretation.

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

## Separation of Duties
- Planning, execution, and audit must remain separate.
- No single role can self-authorize and self-audit the same action.
- Role conflicts must be recorded in decision-log before rollout.
