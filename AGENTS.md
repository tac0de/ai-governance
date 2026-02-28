This repository is architecturally governed.

# Scope

This repository is governance core only.
It defines deterministic verdict logic, evidence contracts, and policy validation.

Product runtime or real MCP implementations are out of scope.

# Trust Boundary

Accept only:
- Evidence contracts
- Replay fixtures
- Deterministic trace logic
- Policy-bound validation

Reject:
- Network-dependent verdict paths
- Randomness or wall-clock dependent logic

# Determinism

Primary quality axis:
same input + same evidence => same verdict.

Trace must remain append-only and hash-referenced.

# Repository Structure

Root directory set is frozen.

Do not modify root-level structure without explicit human architect approval.

Place artifacts under:
- control/
- policies/
- schemas/
- scripts/
- services/

Governed artifacts must use JSON contracts.
`docs/` is non-contract.
Root `README.md` is the only human-facing Markdown.

# Governance Routing

Work affecting governed artifacts must be trace-linked to:
- intent
- policy
- evidence reference

Direct service-side bypass is not allowed.

# Approval Escalation

Human architect approval required when:
- Root structure changes
- Risk tier increases
- Deterministic guarantees are impacted

All other work may proceed within scope.