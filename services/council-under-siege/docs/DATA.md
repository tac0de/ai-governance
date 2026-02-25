# DATA

## Data Contract Surface
- Objective text: `tmp/pm_objective_*.txt`
- Bridge intent: `tmp/*.intent.local.json`
- MCP request artifact: `reports/governance/mcp-request-*.json`
- Trace records: `traces/bridge/*`

## Evidence Policy
- Evidence refs are hash-addressed and append-only in trace linkage.
- Deterministic verdict path must not depend on wall-clock, randomness, or network.

## Retention Notes
- Governance artifacts are treated as audit records.
- Trace logs are immutable append history unless explicit governance cleanup policy is introduced.
