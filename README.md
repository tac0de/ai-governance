# ai-governance v0.7.5

Simple, readable governance for independent AI services.

This repository is a small public contract kernel.

## English

### What This Is

`ai-governance` defines:

- contracts
- schemas
- policies
- validation rules
- continuous monitoring rules
- API-key-based link authorization
- approval-receipt-gated external cleanup

It does not run products.
It does not own service code.
It does not keep service runtime state.

### Operating Model

The flow is fixed:

1. Work enters through a temporary link.
2. Governance is attached to the service as the `governance/` folder only.
3. The scan still reads the whole repository, not only `governance/`.
4. An API-key link contract authenticates the link before repository-wide scanning begins.
5. Cleanup outside `governance/` is allowed only when an approval receipt explicitly permits the target scope.
6. The service emits baseline scans, hygiene reports, and reflection packets.
7. Governance validates structure, auth state, trace state, and release gates.
8. Release is allowed only when required scans, approvals, and reflection gates are clear.

If a required scan is missing, the link is incomplete and release stays blocked.

### What Every Service Must Expose

Every independent service is expected to expose three small public-facing surfaces:

- `governance/`
- `orchestration/`
- `prompts/`

Minimum kernel:

- `README.md`
- `service.yaml`
- `.gitignore`
- `governance/service.contract.json`
- `governance/VERSION`
- `governance/policies/`
- `governance/bin/`
- `governance/plan.json`
- `governance/dtp/`
- `governance/links/active/<link-id>/auth.contract.json`
- `governance/links/active/<link-id>/approval.receipt.json`
- `governance/evidence/`
- `governance/reviews/`
- `governance/monitoring/`
- `orchestration/service.map.yaml`
- `orchestration/stack.profile.yaml`
- `orchestration/package-policy.yaml`
- `orchestration/execution.plan.md`
- `prompts/ideation.md`
- `prompts/macro-planning.md`
- `prompts/tech-selection.md`
- `prompts/implementation-kickoff.md`
- `prompts/review-recovery.md`

Everything else stays local to the service, but whole-repository read scans are still allowed for linking, hygiene classification, and approved cleanup review. Cleanup outside `governance/` is valid only when both the auth contract and approval receipt are active and evidence-linked.

### Language Policy

Core repository formats:

- `json`
- `yaml`
- `sh`

Optional helper language:

- `py`

Not used in `v0.7.5`:

- `rust`

### Repository Layout

- `control/`
  Contracts and registries
- `policies/`
  Boundary rules
- `schemas/`
  Validation schemas
- `scripts/`
  Deterministic validation and trace utilities
- `docs/`
  Public landing surface

### Validation

```bash
bash scripts/validate_all.sh
```

This checks:

- repository shape
- contract validity
- fixed baseline drift

### Why It Exists

The goal is simple:

- easy to read
- easy to validate
- hard to drift silently

This repository is a governance kernel, not a runtime platform.

## 한국어

### 이 저장소는 무엇인가

`ai-governance`는 공개용으로 읽기 쉬운 작은 계약 커널입니다.

이 저장소가 정의하는 것은 다음입니다.

- 계약
- 스키마
- 정책
- 검증 규칙
- 지속 모니터링 규칙
- API key 기반 링크 인증
- approval receipt 기반 외부 정리 통제

이 저장소는:

- 제품을 실행하지 않고
- 서비스 코드를 소유하지 않고
- 서비스 런타임 상태를 보관하지 않습니다

### 동작 방식

흐름은 고정되어 있습니다.

1. 작업이 temporary link로 들어옵니다.
2. 거버넌스는 서비스에 `governance/` 폴더 형태로만 부착됩니다.
3. 하지만 스캔은 `governance/`만이 아니라 저장소 전체를 읽습니다.
4. API key 링크 계약이 저장소 전체 스캔 전에 링크를 인증합니다.
5. `governance/` 밖 정리는 approval receipt가 명시적으로 허용한 범위에서만 가능합니다.
6. 서비스가 baseline 스캔, hygiene report, reflection packet을 남깁니다.
7. 거버넌스가 구조, 인증 상태, trace 상태, release gate를 검증합니다.
8. 필수 스캔, 승인, reflection gate가 모두 깨끗할 때만 release가 가능합니다.

필수 스캔이 하나라도 없으면 link는 incomplete 상태이고, release는 차단됩니다.

### 모든 서비스가 드러내야 하는 최소 표면

모든 독립 서비스는 아래 3개의 작은 공개 표면을 가져야 합니다.

- `governance/`
- `orchestration/`
- `prompts/`

최소 커널은 다음과 같습니다.

- `README.md`
- `service.yaml`
- `.gitignore`
- `governance/service.contract.json`
- `governance/VERSION`
- `governance/policies/`
- `governance/bin/`
- `governance/plan.json`
- `governance/dtp/`
- `governance/links/active/<link-id>/auth.contract.json`
- `governance/links/active/<link-id>/approval.receipt.json`
- `governance/evidence/`
- `governance/reviews/`
- `governance/monitoring/`
- `orchestration/service.map.yaml`
- `orchestration/stack.profile.yaml`
- `orchestration/package-policy.yaml`
- `orchestration/execution.plan.md`
- `prompts/ideation.md`
- `prompts/macro-planning.md`
- `prompts/tech-selection.md`
- `prompts/implementation-kickoff.md`
- `prompts/review-recovery.md`

그 외 구현은 서비스 로컬에서 자유롭게 유지합니다. 다만 링킹, 위생 분류, 승인된 정리 검토를 위해 저장소 전체 읽기 스캔은 허용됩니다. `governance/` 밖 정리는 auth contract와 approval receipt가 모두 활성 상태이고 증빙이 연결되어 있을 때만 유효합니다.

### 언어 원칙

코어 형식:

- `json`
- `yaml`
- `sh`

선택 보조 언어:

- `py`

`v0.7.5`에서 사용하지 않는 언어:

- `rust`

### 저장소 구조

- `control/`
  계약과 레지스트리
- `policies/`
  경계 규칙
- `schemas/`
  검증 스키마
- `scripts/`
  결정적 검증 및 trace 유틸
- `docs/`
  공개 랜딩 표면

### 검증

```bash
bash scripts/validate_all.sh
```

이 스크립트는 다음을 확인합니다.

- 저장소 구조
- 계약 JSON의 형태
- 기준선 해시 드리프트

### 왜 공개하는가

목표는 단순합니다.

- 쉽게 읽히고
- 쉽게 검증되고
- 조용한 구조 드리프트가 어렵게 만드는 것

이 저장소는 런타임 플랫폼이 아니라, 거버넌스 커널입니다.
