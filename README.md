# ai-governance

ai-governance is a deterministic, schema-enforced execution and audit framework.

## Runtime Baseline

The current runtime architecture is:

- Primary runtime: control-plane-go
- Integrity module: audit-core/rust
- Legacy runtime: .legacy/hub (TypeScript, deprecated and not used)

Only control-plane-go and audit-core/rust are part of the supported execution path.

The directory .legacy/hub is retained for historical reference and must not be used in development, testing, or quickstart flows.

## Architecture Overview

- control-plane-go
 - Orchestration
 - Process control
 - I/O handling
 - Schema validation

- audit-core/rust
 - Canonicalization
 - SHA-256 hashing
 - Checksum verification
 - Deterministic integrity enforcement

control-plane-go invokes audit-core/rust for integrity-sensitive operations.

## Quickstart

Prerequisites:

- Go (stable)
- Rust (stable toolchain)

Build and run primary runtime:

- Build Go runtime from control-plane-go
- Build Rust integrity module from audit-core/rust

Do not use .legacy/hub for quickstart or execution.

## Determinism

All audit flows must:

- Pass JSON Schema validation
- Produce deterministic canonical serialization
- Match SHA-256 checksums for plan/result/evidence

Integrity verification is enforced by audit-core/rust.

## Operations (Single View)

This repository uses a secrets tier model for conservative automation.

- `none`: no secrets required
- `admin-only`: requires `OPENAI_ADMIN_API_KEY`
- `repo-write`: requires `OPENAI_ADMIN_API_KEY` and `REPO_ACCESS_TOKEN`

Workflows:
- `governance-autonomous-sweep`: supports `workflow_dispatch` input `secret_tier`
- `release-governance-gate`: supports `workflow_dispatch` input `secret_tier`

Resolution order:
1. `workflow_dispatch` input `secret_tier`
2. repository variable `SECRET_TIER`
3. fallback `admin-only`

If required secrets for selected tier are missing, workflow fails immediately.
Policy source: `constitution/policies/OPERATING_PROFILE_MATRIX_V1.md`
- role-command policy: `constitution/policies/ROLE_COMMAND_AUTHZ_POLICY_V1.md`
- release gate policy: `constitution/policies/RELEASE_GOVERNANCE_GATE_POLICY_V1.md`

### Action Required

- `audit.status != PASS`
- `reason_code != null`
- `secret tier gate failed`

## Delivery Track (Design -> Build -> Validate)

1. Design Lock
- Freeze architecture intent, governance boundary, and acceptance criteria.
- No implementation changes are allowed before design lock.

2. Build
- Implement only within the locked design scope.
- Keep runtime behavior deterministic and schema-enforced.

3. Validate
- Validate API/contract behavior first.
- Validate UI/UX quality as a separate step when needed.
- Playwright is a validation tool for this stage, not a design or implementation prerequisite.
