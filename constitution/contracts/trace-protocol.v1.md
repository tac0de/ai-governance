# Deterministic Trace Protocol v1

## Purpose
Define a reproducible envelope linking `plan`, `result`, and `evidence` artifacts for audit.

## Time Reference
- KST: `2026-02-20T15:43:12+09:00`
- UTC: `2026-02-20T06:43:12Z`

## Normative Principles
1. Schema-first contracts are mandatory.
2. Outputs must be deterministic for identical inputs and policy context.
3. Every trace must be verifiable from evidence artifacts and checksums.

## Trace Envelope Fields
Required envelope fields by contract:

- `request_id`
- `governance_layer` (`internal_government` or `external_enterprise`)
- `ministry_id`
- `jurisdiction`
- `pr_ref`
- `toolchain` (`bash`, `git`, `gh`)
- `determinism_id`
- `plan_hash`
- `result_hash`
- `artifact_manifest_hash`
- `repro_run_id`

## Layer Boundary Rule
- Internal government authority and external enterprise authority must not be mixed in one command path.
- Cross-jurisdiction invocation must be explicitly policy-approved; otherwise it is denied.

## Acceptance Invariants
1. `runner` must be `bash`.
2. `plan_hash`, `result_hash`, and `checksums` must be consistent.
3. `pr_ref` must be present for merge-impacting runs.

## Failure Mapping
If validation fails, auditor must emit one of:
- `HUNBUP_PR_GATE_MISSING`
- `HUNBUP_TOOLCHAIN_VIOLATION`
- `HUNBUP_MINISTRY_SCOPE_VIOLATION`

## Linked Contracts
- `schemas/jsonschema/plan.schema.json`
- `schemas/jsonschema/result.schema.json`
- `schemas/jsonschema/evidence.schema.json`
- `schemas/jsonschema/audit.schema.json`
- `constitution/contracts/mcp-authority-unit-table.v1.md`
