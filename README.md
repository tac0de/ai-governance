# ai-governance v0.5

Deterministic governance kernel for a `casting director` architecture with linked services.

Release line: `v0.5`

## Core Identity

`ai-governance` is the central contract layer.

It defines:
- role and department structure
- governance lanes
- temporary-link scan gates
- linked-service kernel expectations
- launch and version promotion gates
- deterministic validation logic

It does not own:
- runtime implementations
- service-local logs
- product UX
- long-lived execution state
- real MCP runtimes

## What Changed in v0.5

`v0.5` closes the gap between `v0.4` direction and actual operating rules.

The three primary upgrades are:
1. `temporary linking` is now governed by mandatory scan points, not just a loose handshake
2. flow is modeled as `role -> department -> department transition`, not only role lists
3. every independent service is expected to expose a minimal governance-facing root kernel while keeping implementation folders free

## Central Ownership Boundary

Central owns only:
- JSON contracts under `control/`
- validation schemas under `schemas/`
- policies under `policies/`
- deterministic validators under `scripts/`

Central does not own:
- runtime repositories
- service-local evidence logs
- app code
- service-specific build structure

## File Philosophy

Preferred artifacts in this repository:
- `README.md` for the single human-facing explanation
- `json` for governed contracts
- `yaml` only when an external tool materially benefits
- shell validators in `scripts/` only when they stay deterministic and local

## Start Here

1. `control/registry/link-scan-points.v0.5.json`
- mandatory 4-stage scan gates for temporary linking

2. `control/registry/temporary-links.v0.5.json`
- completion, incomplete, and residue rules for linked work

3. `control/agents/departments.v0.5.json`
- the canonical department state model

4. `control/registry/department-flow.v0.5.json`
- the allowed department-to-department handoff graph

5. `control/agents/role.catalog.v0.5.json`
- role catalog with department placement

6. `control/registry/service-kernel.v0.5.json`
- the common governance-facing root kernel for independent services

7. `control/registry/linked-services.v0.5.json`
- the primary linked service catalog for new work

8. `control/registry/launch-readiness.v0.5.json`
- operational readiness gate before a service can be treated as launch-ready

9. `control/registry/service-normalization.v0.5.json`
- one-time pass for bringing an existing independent service into the v0.5 governance shape

10. `control/registry/service-diet.v0.5.json`
- scan-and-archive pass for trimming unnecessary surfaces in an already linked independent service

11. `control/registry/version-promotion.v0.4.json`
- the still-active `v1.0` business-use gate

12. `scripts/validate_all.sh`
- deterministic validation gate for the governed surface

## One-Line Architecture

`intake scan -> scoped temporary link -> service-local execution -> review gate -> launch readiness -> version promotion`

## Governance Model

### 1. Four-Stage Scan Gate

Temporary linking is now closed by required scans:
- `intake-scan`
- `pre-exec-scan`
- `post-exec-scan`
- `pre-release-scan`

Rules:
- `exploration` requires at least the first three
- `production` requires all four
- missing required scans leave the link `incomplete`
- incomplete links cannot be treated as releasable

### 2. Department-State Flow

The primary control surface is now the department graph, not free-form role assignment.

Core departments:
- `intake-routing`
- `build-execution`
- `specialist-studio`
- `review-gate`
- `release-council`

Meaning:
- roles are assignable people/capabilities
- departments are stable state buckets
- handoffs are governed between departments, not negotiated ad hoc between individuals

### 3. Linked Service Kernel

Every independent service should expose a minimal governance-facing root kernel:
- `README.md`
- `service.yaml`
- `governance/service.contract.json`
- `governance/links/`
- `governance/evidence/`
- `governance/reviews/`
- `.gitignore`

This keeps governance interfaces consistent while allowing app code layout to remain free.

Implementation folders such as:
- `app/`
- `src/`
- `server/`
- `packages/`
- `workers/`
- `tools/`

remain service-local decisions.

### 4. Launch Ready vs v1.0

`launch-ready` and `v1.0` are intentionally different.

`launch-ready` means:
- operational runbook exists
- rollback exists
- operator ownership exists
- evidence is fresh enough
- pre-release scan passed

`v1.0` still means:
- market proof exists
- the human architect actively uses the service as a business instrument
- production stability is proven

So the ladder is:
- `pre-launch`
- `launch-ready`
- `v1.0`

### 5. One-Time Service Normalization

Existing independent services do not need to be permanently reowned by central governance.

Instead, central can run a one-time `service normalization pass`:
- temporarily link to the service
- align the minimum governance-facing root
- align evidence and review receipts
- mark the service as `normalized`
- release the link

This is how older independent services can be cleaned up without turning central governance into a permanent runtime dependency.

### 6. Service Diet

Normalization makes a service legible to governance.
`service diet` makes a service lighter.

This is the scan used to:
- identify dead surfaces
- identify duplicated surfaces
- identify stale governance leftovers
- decide what is safe to archive

Central still does not take custody of the runtime.
It only issues the scan logic and the archive decision surface.
The service archives its own unnecessary material.

## Services in v0.5

`services/` is no longer an active onboarding surface.

In `v0.5`:
- no new service should be onboarded by adding a new `services/<id>/` seed
- `control/registry/services.v0.1.json` is a legacy-only seed catalog
- `scripts/validate_seed_catalog.sh` remains for compatibility
- `scripts/bootstrap_service.sh` remains disabled unless explicitly overridden

Current onboarding should prefer:
- `control/registry/linked-services.v0.5.json`
- `control/registry/service-kernel.v0.5.json`
- `control/registry/temporary-links.v0.5.json`
- `control/registry/service-normalization.v0.5.json` for existing services that need cleanup
- `control/registry/service-diet.v0.5.json` when an existing service needs clutter reduction

## Practical Rule of Thumb

If a service asks:
- "Who should work on this?" -> consult `role.catalog.v0.5`
- "Which state should this work enter next?" -> consult `department-flow.v0.5`
- "Can central help temporarily?" -> consult `temporary-links.v0.5`
- "What minimum structure must the service expose?" -> consult `service-kernel.v0.5`
- "Can this go live?" -> consult `launch-readiness.v0.5`
- "Can this be called v1?" -> consult `version-promotion.v0.4`

If the question is:
- "Where should logs live?" -> in the service repo
- "Where should runtime code live?" -> in the service repo
- "Where should experiments happen?" -> in the service repo

## Validation

Primary validation:

```bash
bash scripts/validate_all.sh
```

Legacy seed compatibility:

```bash
bash scripts/validate_seed_catalog.sh
```

Legacy seed bootstrap override only:

```bash
LEGACY_SEED_BOOTSTRAP_APPROVED=1 bash scripts/bootstrap_service.sh ...
```

## Status

`v0.5` is the operating architecture line.

It is the version where:
- central looks like a real governance kernel
- linked services have a standard governance-facing shape
- flow control is explicit enough to scale

It is not yet `v1.0`.

`v1.0` starts only when the service is actually useful in the market and actively used in the architect's business work.
