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
- Place new artifacts under existing roots first; prefer `control/`, `services/`, `mcps/`, `policies/`, `schemas/`, and `scripts/`.
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
