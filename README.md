# ai-governance v0.4

Deterministic governance kernel for `casting director` style architecture.

Release line: `v0.4`

## Core Identity

`ai-governance` is no longer the place where services are centrally managed.

It is the central place where:
- roles are defined
- governance lanes are defined
- leaseable capabilities are cataloged
- temporary link rules are issued
- evidence and review contracts are validated

It is not the place where:
- runtime implementations live
- service logs are centrally stored
- product UX or application logic is developed
- long-lived service state is coordinated

## v0.4 Architectural Shift

The repository now targets a `casting director` model:

- Central decides **who should act**
- Central decides **which lane the work belongs to**
- Central decides **which capability may be temporarily linked**
- Services execute locally in their own repositories
- Services own their own logs, runtime traces, and operational memory
- Central receives only reviewable evidence contracts and link receipts

This replaces the older `bootstrap compiler + seed catalog` emphasis as the primary mental model.

## What Central Owns

Central ownership is limited to:
- governance registries under `control/registry/`
- role and department catalogs under `control/agents/`
- MCP capability contracts under `control/mcps/`
- policies under `policies/`
- schemas under `schemas/`
- minimal validators and packagers under `scripts/`

Central does not own:
- runtime service repositories
- runtime logs
- real MCP implementations
- service-local experimentation context

## File Philosophy

Preferred artifact types in this repository:
- `README.md` for the single human-facing root explanation
- `json` for governed contracts and registries
- `yaml` only where CI or external tooling specifically benefits
- minimal shell validators in `scripts/` for deterministic checking

`AGENTS.md` is intentionally removed in v0.4.
Its intent is absorbed into this `README.md`.

## Start Here

1. `control/agents/role.catalog.v0.4.json`
- canonical role catalog for specialist assignment

2. `control/registry/lanes.v0.4.json`
- separates `exploration` and `production`

3. `control/registry/temporary-links.v0.4.json`
- defines the temporary-link handshake between central governance and independent services

4. `control/registry/linked-services.v0.4.json`
- optional map of externally owned services known to central governance

5. `control/registry/capabilities.v0.4.json`
- canonical leaseable capability registry for the casting-director model

6. `control/registry/version-promotion.v0.4.json`
- deterministic rule for when a governed service is allowed to call itself `v1.0`

7. `control/registry/mcps.v0.1.json`
- legacy MCP registry retained for compatibility

8. `scripts/validate_all.sh`
- deterministic validation gate for the current governed surface

## One-Line Architecture

`roles + lanes + capability contracts + temporary links -> local service execution -> evidence contract review`

## Governance Model

### 1. Dual Lane

- `exploration`
  - used for discovery, creative work, early architecture, visual R&D
  - low-friction, temporary link by default
  - contracts are lighter and allowed to evolve

- `production`
  - used for deploy, policy, data, security, irreversible changes
  - stricter gates and stronger evidence
  - contracts are expected to be stable and reviewable

### 2. Capability Leasing

MCPs and specialist roles are treated as leaseable capabilities, not centrally hosted runtime dependencies.

Examples:
- `visual-critic`
- `temporary-link-routing`
- `release-review`
- `core-analytics-mcp`
- `core-experiment-mcp`
- `core-safety-fallback-mcp`
- `core-governance-journal-mcp`
- `core-experience-profile-mcp`

The real implementation may live elsewhere.
Central keeps the contract, capability definition, and approval rules.
`control/registry/capabilities.v0.4.json` is the preferred source of truth.
`control/registry/mcps.v0.1.json` remains as a compatibility surface for older bootstrap flows.

### 3. Version Promotion

`v1.0` is not a completeness badge.
In v0.4, `v1.0` means:
- market usefulness is evidenced
- the human architect actively uses the service as a business instrument
- production review is stable enough to justify the label

The canonical gate is:
- `control/registry/version-promotion.v0.4.json`

### 4. Temporary Linking

Services should link to central governance temporarily:
- request role/capability
- receive lane constraints
- execute locally
- return evidence
- release the link

This avoids over-constraining creative and service-local work while preserving reviewability.

### 5. Review-First

Central should prefer:
- review contracts
- evidence validation
- failure pattern detection

Central should avoid:
- dictating implementation details too early
- owning service runtime memory
- becoming a cross-service orchestration bottleneck

## Services in v0.4

`services/` is no longer a required long-term concept.

Current rule:
- `services/` is legacy seed/archive territory only
- it is not the preferred center of gravity for new governance work
- service-local logs belong to each service repository, not here

Near-term transition rule:
- existing `services/` content remains for backward compatibility
- new architecture should prefer `linked-services.v0.4.json` over adding new seed-heavy service folders

Planned direction:
- shrink `services/`
- keep only legacy references or migration archives as needed
- move the central model toward role/capability/lane contracts

## Quick Validation

```bash
bash scripts/validate_all.sh
```

Legacy compatibility checks still exist while seed-era assets remain:

```bash
bash scripts/validate_seed_catalog.sh
```

Legacy bootstrap remains available only by explicit override:

```bash
LEGACY_SEED_BOOTSTRAP_APPROVED=1 bash scripts/bootstrap_service.sh ...
```

## Current v0.4 Contract Surface

- `control/agents/departments.v0.1.json`
- `control/agents/role.catalog.v0.4.json`
- `control/registry/org.v0.1.json`
- `control/registry/mcps.v0.1.json`
- `control/registry/services.v0.1.json` (legacy seed catalog)
- `control/registry/linked-services.v0.4.json`
- `control/registry/lanes.v0.4.json`
- `control/registry/temporary-links.v0.4.json`
- `control/registry/capabilities.v0.4.json`
- `control/registry/version-promotion.v0.4.json`

## Practical Rule of Thumb

If a service asks:
- "Who should work on this?" -> consult role catalog
- "How constrained is this work?" -> consult lane policy
- "Can central help temporarily?" -> consult temporary link contract
- "What capability can be borrowed?" -> consult capability registry first, MCP registry second for compatibility
- "Is this ready to be called v1?" -> consult version-promotion policy

If the question is:
- "Where should logs live?" -> in the service repo
- "Where should runtime code live?" -> in the service repo
- "Where should experimental implementation happen?" -> in the service repo

## Status

v0.4 is the architectural direction line.

Backward compatibility remains for:
- legacy seed-oriented service catalog contracts
- existing validation scripts that still reference `services/`
- explicit opt-in seed bootstrap via `scripts/bootstrap_service.sh`

Future cleanup can remove more seed-era assumptions after the new role/lane/link model is fully adopted.
