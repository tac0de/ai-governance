This repository is architecturally governed.

# Scope

- This file defines repository governance for `ai-governance`.
- These rules are model-agnostic and apply to any agent used in this repository.

# Trust Boundary

- This repository is governance core only.
- Do not implement product runtime or real MCP implementations in this repository.
- Accept only evidence contracts, replay fixtures, deterministic trace logic, and policy-bound validation.

# Determinism Policy

- Primary quality axis: same input + same evidence => same verdict.
- Reject changes that add wall-clock, randomness, or network dependency to verdict path.
- Keep trace append-only and hash-referenced.

# Closure Policy

- Prefer versioned closure over open-ended expansion.
- Freeze opcode and schema versions for each release line.
- New capabilities must be adapterized outside core and integrated through conformance artifacts.

# Repository Shape Freeze

- Keep the root top-level directory set stable.
- Do not add, remove, or rename root-level directories without explicit human architect approval.
- Place new artifacts under existing roots first; prefer `control/`, `policies/`, `schemas/`, `scripts/`, `agents/`, `prompts/`, `services/`, and `mcps/`.
- Treat root-level structure changes as high-risk governance changes.

# AGENTS Hierarchy

- Policy precedence is strict: repository root `AGENTS.md` > `services/<service>/AGENTS.md`.
- A service-level `AGENTS.md` is optional and may only narrow scope for that service.
- Service-level rules must not broaden tool access, approval tiers, or evidence/trace obligations defined at root.
- Any conflict is resolved by root `AGENTS.md`.
- Human override authority remains centralized at root governance policy.

# Execution Guardrails

- Keep changes minimal, deterministic, and testable via shell scripts.
- Prioritize API-level verification; use UI-level checks only when explicitly required.
- For high-risk boundary changes, require explicit human architect approval.

# Default Reporting Format

- Use the following report format as the default response structure, even when context changes:
- `1. WHAT I DID`
- `2. WHERE IT IS RUNNING`
- `3. HUMAN REQUIRED (links + paths)`
- `4. RISK / UNKNOWN`
- Korean aliases are allowed and recommended in parallel:
- `1. WHAT I DID (무엇을 했는가)`
- `2. WHERE IT IS RUNNING (어디서 실행되는가)`
- `3. HUMAN REQUIRED (links + paths) (사람 확인 필요: 링크 + 경로)`
- `4. RISK / UNKNOWN (위험 / 미확정)`
- Allow exceptions only for clearly exceptional cases.
- Maintain partial autonomy while still preferring this format by default.
- Prefer this exact numbered order unless an exceptional case is explicitly stated.

# Planning Gate and Autopilot

- Prefer a single macro planning gate over repeated micro-approvals.
- Planning gate must capture: objective, scope, forbidden actions, risk tier, completion criteria, and rollback condition.
- After planning approval, agents should execute in autopilot mode within approved scope.
- Do not require extra human approval for routine steps that stay in approved scope.
- Trigger interrupt-and-ask only when one of the following occurs:
- Scope deviation is required.
- Risk tier increases beyond approved level.
- Critical validation fails or rollback condition is hit.
- In autopilot mode, keep human updates concise and decision-focused.
- End each execution cycle with one final report using the default reporting format.

# Mandatory Governance Path

- All work must follow governance-enforced routing by default.
- Direct service-side execution without governance contract linkage is not allowed.
- Every execution unit must be trace-linked to intent, policy, and evidence references.
- Service repositories may implement details, but must not bypass central governance gates.
- Exceptions require explicit human architect override and must be recorded in trace artifacts.
