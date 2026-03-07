# ai-governance v0.8.0

Simple, readable governance for independent AI services.

This repository is a small public control kernel.

## English

### What This Is

`ai-governance` defines:

- contracts
- schemas
- policies
- deterministic validation rules
- docs evolution prompts and public landing surfaces
- service-link intake and release gates
- deployment and domain operations contracts for GCP-oriented services
- solution packaging tiers for audit, governance setup, and monitoring link offers
- cognitive debt contracts that turn agent risk into reviewable technical debt
- specialist MCP recommendation registries

It does not run products.
It does not own service code.
It does not host real MCP runtimes.
It does not keep service runtime state.

### Operating Model

The boundary is fixed:

1. Central governance is the control plane.
2. Independent services are the execution plane.
3. Work enters through a link and remains gated by auth, packets, and receipts.
4. The intake path is `handbook -> link auth -> repository scan -> normalization/diet -> deployment topology -> draft plan -> request gate`.
5. Central governance may define policy, registries, upgrade loops, and package logic.
6. Independent services keep runtime entrypoints, deployment scripts, domain cutover, and monitoring execution.
7. Release claims stay blocked when scans, receipts, debt posture, or gate state are incomplete.

### v0.8.0 Adds

- a mission-control docs surface with richer but bounded motion
- `solution-packaging.v0.8.json`
- `cognitive-debt-ledger.v0.8.json`
- `specialist-mcp-registry.v0.8.json`
- `monitoring-link.v0.8.json`
- contract-only solution packs for:
  - `tier-1` audit only
  - `tier-2` audit + governance setup
  - `tier-3` audit + governance setup + monitoring link

The docs landing is now a public operator console, not a neutral showcase. JSON keeps hard edges. Markdown carries role prompts, narrative pressure, and visual direction.

### Docs Surface

`docs/` stays a static deploy surface.

- `docs/index.html`, `docs/assets/site.css`, `docs/assets/site.js`
- `docs/role-prompt-registry.json`
- `docs/version-upgrade-loop.json`
- `docs/version-upgrade-proposal.json`
- generated docs mirrors for solution packaging, cognitive debt, specialist MCPs, and monitoring link
- `docs/prompts/*.md`

`bash scripts/refresh_docs_evolution.sh` refreshes the generated docs mirror JSON and proposal outputs from the current registry state.

### Repository Layout

- `control/`
  Contracts and registries
- `policies/`
  Boundary rules
- `schemas/`
  Validation schemas
- `scripts/`
  Deterministic validation and docs refresh utilities
- `packs/`
  Installable packs and contract-only solution packaging surfaces
- `docs/`
  Public landing and operating prompt surface

### Validation

```bash
bash scripts/refresh_docs_evolution.sh
bash scripts/validate_all.sh
```

This checks:

- repository shape
- contract validity
- docs surface drift
- baseline drift
- pack surface completeness

### Why It Exists

The goal is simple:

- easy to read
- easy to validate
- hard to drift silently
- explicit about who owns judgment versus execution

This repository is a governance kernel, not a runtime platform.

## 한국어

### 이 저장소는 무엇인가

`ai-governance`는 독립서비스를 위한 작은 공개 control kernel입니다.

이 저장소는 다음을 정의합니다.

- 계약
- 스키마
- 정책
- 결정론적 검증 규칙
- docs 진화용 prompt 및 공개 landing surface
- 서비스 link intake 및 release gate
- GCP 지향 서비스용 deployment/domain operations 계약
- audit, governance setup, monitoring link를 위한 solution packaging tier
- 에이전트 리스크를 기술 부채 표면으로 올리는 cognitive debt 계약
- specialist MCP 추천 레지스트리

이 저장소는:

- 제품을 실행하지 않고
- 서비스 코드를 소유하지 않고
- 실제 MCP 런타임을 호스팅하지 않고
- 서비스 런타임 상태를 저장하지 않습니다

### 동작 모델

경계는 고정입니다.

1. 중앙 거버넌스는 control plane입니다.
2. 독립서비스는 execution plane입니다.
3. 작업은 link로 들어오고 auth, packet, receipt에 의해 통제됩니다.
4. intake 순서는 `handbook -> link auth -> repository scan -> normalization/diet -> deployment topology -> draft plan -> request gate`입니다.
5. 중앙 거버넌스는 정책, 레지스트리, upgrade loop, package logic만 정의합니다.
6. 독립서비스는 runtime entrypoint, deploy script, domain cutover, monitoring 실행을 유지합니다.
7. 스캔, receipt, debt posture, gate 상태가 불완전하면 release 문구는 열리지 않습니다.

### v0.8.0에서 추가된 것

- 더 시스템적인 mission-control docs surface
- `solution-packaging.v0.8.json`
- `cognitive-debt-ledger.v0.8.json`
- `specialist-mcp-registry.v0.8.json`
- `monitoring-link.v0.8.json`
- contract-only solution pack:
  - `tier-1` 점검만
  - `tier-2` 점검 + 거버넌스 세팅
  - `tier-3` 점검 + 거버넌스 세팅 + monitoring link

이제 landing은 단순 쇼케이스가 아니라 공개 operator console입니다. JSON은 hard edge를 유지하고, Markdown은 role prompt, narrative, visual direction을 맡습니다.

### Docs Surface

`docs/`는 계속 정적 배포 표면입니다.

- `docs/index.html`, `docs/assets/site.css`, `docs/assets/site.js`
- `docs/role-prompt-registry.json`
- `docs/version-upgrade-loop.json`
- `docs/version-upgrade-proposal.json`
- solution packaging, cognitive debt, specialist MCP, monitoring link용 docs mirror JSON
- `docs/prompts/*.md`

`bash scripts/refresh_docs_evolution.sh`는 현재 registry 상태를 기준으로 docs용 mirror JSON과 proposal 산출물을 갱신합니다.

### 검증

```bash
bash scripts/refresh_docs_evolution.sh
bash scripts/validate_all.sh
```

이 검증은 다음을 봅니다.

- 저장소 구조
- 계약 유효성
- docs surface drift
- baseline drift
- pack surface 완결성

### 왜 존재하는가

목표는 단순합니다.

- 읽기 쉽고
- 검증하기 쉽고
- 조용히 drift 되기 어렵고
- 판단과 실행의 책임 경계를 분명히 하는 것

이 저장소는 governance kernel이지 runtime platform이 아닙니다.
