# ADR-0003: Keep Role Model Technology-Neutral (MCP Optional)

## Status
Accepted

## Related ADR
- Supplemental operational binding: `ADR-0006-hybrid-mcp-governance-binding.md`

## Context
The v1 role model separates AI Government and AI Enterprise responsibilities.
There is a risk of coupling governance roles to implementation protocols (for example MCP),
which can blur accountability boundaries.

## Decision
The governance role model is technology-neutral:
- Role definitions and authority boundaries are independent of protocol choices.
- MCP is treated as an optional integration mechanism in implementation.
- Policy and audit decisions must not require a protocol-specific dependency.

## Consequences
- Positive: clearer role accountability and lower architecture lock-in.
- Constraint: protocol adoption must be documented as implementation detail,
  not as constitutional role change.
- Enforcement: role/policy documents remain protocol-agnostic unless explicitly revised by ADR.
