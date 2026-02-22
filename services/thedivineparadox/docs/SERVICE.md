# SERVICE

## Purpose
- Provide governance-grade strategic insights from evidence bundles while preserving deterministic validation boundaries.
- Ensure every insight is explainable and traceable to evidence refs and trace refs.

## Primary User
- Platform owners and architects who approve policy, risk, and change decisions.

## Boundaries
- In scope: evidence summarization contracts, policy-conflict narrative generation, scenario recommendation drafting, and governance documentation.
- Out of scope: product runtime execution logic, network-dependent verdict generation paths, and autonomous high-risk decision execution.

## Decision Principles
- Evidence-first: no strategic insight without explicit evidence refs.
- Explainability-first: outputs must include rationale and trace linkage.
- Policy-first: approval tier and profile constraints are mandatory.

## Dependencies
- `policies/policy_profiles.v0.1.json`
- `policies/approval_tier_policy.v0.1.json`
- `control/registry/mcps.v0.1.json`
- `specs/trace_rules.v0.1.md`

## Owner
- Team: Platform Operations
- Contact: platform-ops-owner
