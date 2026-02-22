# Change Management Playbook

## Change Intake
- Every service or MCP change must include policy impact and approval tier classification.
- Runtime architecture upgrades in service-node repositories must include a central-governance handoff note with:
  - deterministic impact statement
  - traceability impact statement
  - fallback continuity statement
  - rollback strategy and expected blast radius

## Review Gates
1. Validate against schemas and fixed document set.
2. Confirm policy profile and MCP allowlist compliance.
3. Run deterministic and benchmark gates.
4. For service-node runtime upgrades, verify deployment gating policy:
   - staging automation allowed
   - production requires explicit human architect approval

## Merge Criteria
- Required approval tier satisfied.
- `scripts/validate_all.sh`, `scripts/test_determinism.sh`, and `scripts/benchmark_gate.sh` pass.
- If runtime upgrade is included, merge must reference a PM execution brief and a release gate owner.
