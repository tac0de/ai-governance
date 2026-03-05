# Governance v0.7.4 Solutionization Contract (B2B)

This document freezes the commercialization-oriented flow for `v0.7.4`.

Target from `v1.0`:
- become deployable as a monetizable commercial governance solution
- preserve strict boundary control and auditable approval gates

Core product experience:
- agent writes the plan
- shell executes the plan
- governance enforces boundaries and gates

## Fixed 6-Stage Flow

1. Intake / Contracting
- Access mode: least privilege, read-first
- Confirm organization policy bundle (`security`, `compliance`, `quality`)
- Output: intake receipt + policy bundle lock

2. Link (Boundary Seal)
- Install path is strictly limited to `/governance/**`
- No root-level or runtime code modification is allowed at link stage
- Required boundary markers:
  - `/governance/VERSION`
  - `/governance/policies/**`
  - `/governance/bin/**`
- Output: boundary-seal receipt

3. Baseline Scan (DTP start)
- Snapshot current state and write DTP evidence:
  - dependency state
  - build status
  - test status
  - Lighthouse/performance budget status
  - security scan status
- Output: baseline receipt (`reality baseline`)
- Daily requirement: append a concrete reflection packet for observed failures and quality gaps

4. Plan (Agent-assisted, structured)
- Agent reads repository and writes only `/governance/plan.json`
- Plan must be schema-constrained and allowlist-scoped
- Example objectives:
  - add Lighthouse CI gate
  - set threshold values
  - define minimum required test scenarios
- Output: deterministic plan artifact

5. Review / Gate
- Human review approval is default
- Policy-based auto approval is optional and explicit
- No changes are allowed before approval
- Approval logs are mandatory audit evidence
- Output: gate verdict + approval log

6. Apply / Release + Monitoring
- `gov apply` can apply only inside `/governance/**`
- CI must pass pre-release scans before release:
  - Lighthouse CI gate
  - security gate
  - policy-compliance gate
- Release result is appended to DTP
- Drift detection re-enters loop from stage 3 to 4
- Output: release receipt + monitoring continuation
- If any out-of-boundary mutation is detected outside `/governance/**`, release is blocked until revert evidence is attached.

## Contracted Path and Ownership

Governance-owned writable path:
- `/governance/**`

Governance-forbidden paths:
- repository root files (except allowed link metadata inside `/governance/**`)
- runtime/service code paths outside `/governance/**`

Execution ownership:
- agent: writes plan artifact
- shell/runner: executes approved plan
- governance kernel: validates boundary and gate compliance

## `/governance/plan.json` Minimum Shape (v0.7.4)

```json
{
  "version": "v0.7.4",
  "plan_id": "string",
  "baseline_ref": "string",
  "policy_bundle_ref": "string",
  "allowlist": {
    "writable_paths": [
      "governance/**"
    ],
    "forbidden_paths": [
      "*"
    ]
  },
  "actions": [
    {
      "id": "string",
      "type": "add_gate|set_threshold|define_test_minimum",
      "target": "string",
      "change": {}
    }
  ],
  "approval": {
    "required": true,
    "status": "pending|approved|rejected"
  }
}
```

Notes:
- This is a contract shape for planning discipline in `v0.7.4`.
- Formal JSON Schema integration is deferred to the next validation-surface update.

## Non-Negotiable Gate Rules

- Missing baseline evidence blocks promotion.
- Missing approval blocks apply.
- Boundary violation blocks release.
- Unreverted out-of-boundary mutation blocks release.
- Pre-release scan failure blocks release.
- Audit trail absence blocks release.

## v1.0 Revenue Readiness Alignment

A service can be considered `v1.x commercial-ready` only if all are true:
- paid or contract-backed external usefulness exists
- policy bundle + approval logs are reproducible
- release gates are deterministic and repeatable
- drift loops are operational (3 -> 4 recovery path proven)
