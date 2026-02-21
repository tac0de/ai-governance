# ai-governance

ai-governance is a human-led governance repository.

## Repository Role

- Supported execution path is core only: `control-plane/go` and `audit-core/rust`.
- This repository owns deterministic governance contracts, schemas, audit/integrity gates.
- MCP implementations are outside trust boundary and are validated here only by replayable conformance fixtures.

## Human Governance First

- Primary output is governance decisions and contracts.
- Internal layer is government authority (boundary, policy, audit).
- External layer is enterprise delivery (market fit, growth, revenue).
- Internal and external authority must remain separated.

## What You Should Read First

1. `constitution/VERY_SIMPLE_KO_BRIEF_V1.md`
2. `constitution/HUMAN_GOVERNANCE_BRIEF_V1.md`
3. `constitution/charter/AI_GOVERNANCE_ROLES_V1.md`
4. `constitution/contracts/trace-protocol.v1.md`
5. `constitution/policies/RELEASE_GOVERNANCE_GATE_POLICY_V1.md`
6. `SKILLS_QUICKSTART_KO.md`

## Decision Baseline

- Role model remains protocol-agnostic at constitutional level.
- Operational execution uses jurisdiction-scoped ministry contracts.
- All change delivery is PR-gated with deterministic evidence.

## Trust Boundary

- Core path: deterministic + schema-enforced + audit/integrity.
- Extension path: MCP implementation runtime (network/time/credentials risk).
- See `docs/architecture/TRUST_BOUNDARY.md` for boundary policy and split plan.

## Technical Appendix

Technical implementation details are intentionally moved out of the main view.
Use `constitution/TECHNICAL_APPENDIX_V1.md` only when runtime-level verification is required.
