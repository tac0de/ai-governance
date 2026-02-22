# Change Management Playbook

## Change Intake
- Every service or MCP change must include policy impact and approval tier classification.

## Review Gates
1. Validate against schemas and fixed document set.
2. Confirm policy profile and MCP allowlist compliance.
3. Run deterministic and benchmark gates.

## Merge Criteria
- Required approval tier satisfied.
- `scripts/validate_all.sh`, `scripts/test_determinism.sh`, and `scripts/benchmark_gate.sh` pass.
