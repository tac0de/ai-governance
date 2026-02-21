# Ops Toolchain Policy v1

## Policy ID
OTP-V1

## Scope
Applies to all governance execution runs and release-delivery changes.

## Time Reference
- KST: `2026-02-20T15:43:12+09:00`
- UTC: `2026-02-20T06:43:12Z`

## Mandatory Toolchain
Every governed run must declare and use:

1. `bash` as runner
2. `git` as immutable change ledger
3. `gh` as workflow and release surface

## PR-Gated Delivery Rule
- Any merge-impacting change must be linked to a pull request reference (`pr_ref`).
- Release or merge without PR-linked evidence is a governance violation.

## Deterministic Evidence Rule
- `plan`, `result`, and `evidence` artifacts must be schema-valid and hash-linked.
- Missing toolchain proof or PR reference must produce deterministic REJECT.

## Enforcement Anchors
- `schemas/jsonschema/plan.schema.json`
- `schemas/jsonschema/result.schema.json`
- `schemas/jsonschema/evidence.schema.json`
- `schemas/jsonschema/audit.schema.json`
- `constitution/policies/RELEASE_GOVERNANCE_GATE_POLICY_V1.md`
