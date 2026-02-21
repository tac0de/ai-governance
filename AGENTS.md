This repository is architecturally governed.

# Local Scope

- This file is repository-local and overrides project behavior only for `ai-governance`.
- Global rules in `$CODEX_HOME/AGENTS.md` remain unchanged and still apply.

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

# Execution Guardrails

- Keep changes minimal, deterministic, and testable via shell scripts.
- Prioritize API-level verification; use UI-level checks only when explicitly required.
- For high-risk boundary changes, require explicit human architect approval.
