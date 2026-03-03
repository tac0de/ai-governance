# ai-governance v0.6

Simple, deterministic governance for independent AI services.

This repository is now shaped for public open-source use.

## English

### What This Is

`ai-governance` is a small central contract layer.

It does not run products.
It does not own service code.
It does not keep service runtime state.

It defines the rules that independent services can follow:
- how work moves through a fixed governance flow
- what scans are required before release
- what minimum governance files a service should expose
- how deterministic trace rules are defined

In short:
- services do the real work
- this repository defines the boundary, checks, and release gates

### What This Is Not

This is not:
- an app framework
- a runtime platform
- a service template generator
- a central log storage system

If a service needs:
- app code
- local traces
- product UX
- deployment logic

that stays in the service repository, not here.

### Core Idea

The operating model is simple:

1. Work enters through intake.
2. A temporary link is opened for scoped work.
3. The service executes locally.
4. Review checks the result.
5. Release only happens if required scans are complete.

Missing a required scan means:
- the link is incomplete
- release is blocked

### Service Rule

Each independent service should expose only a small governance-facing surface:

- `README.md`
- `service.yaml`
- `governance/service.contract.json`
- `governance/dtp/`
- `governance/links/active/`
- `governance/evidence/`
- `governance/reviews/`
- `.gitignore`

Everything else stays service-local and free.

### Repository Layout

This repository intentionally stays small:

- `control/`  
  Governance contracts and registries
- `policies/`  
  Boundary rules
- `schemas/`  
  Validation schemas
- `scripts/`  
  Deterministic validation and trace utilities
- `docs/`  
  Human-readable public documentation

### Validate

```bash
bash scripts/validate_all.sh
```

This checks:
- repository shape
- contract validity
- fixed baseline drift

### Public Open-Source Intent

This repository is meant to be readable by humans first.

The goal is:
- easy to inspect
- easy to validate
- hard to drift silently

It is a governance kernel, not a product runtime.

## 한국어

### 이 저장소는 무엇인가

`ai-governance`는 아주 작은 중앙 계약 레이어입니다.

이 저장소는:
- 제품을 실행하지 않습니다
- 서비스 코드를 소유하지 않습니다
- 서비스 런타임 상태를 보관하지 않습니다

대신, 독립 서비스들이 따라야 할 규칙을 정의합니다.

- 작업이 어떤 고정된 흐름으로 이동하는지
- 릴리스 전에 어떤 스캔이 필요한지
- 서비스가 어떤 최소 거버넌스 파일을 드러내야 하는지
- 결정적 트레이스(DTP) 규칙을 어떻게 유지하는지

한 줄로 말하면:
- 실제 일은 서비스가 하고
- 이 저장소는 경계, 검증, 릴리스 게이트를 정의합니다

### 이 저장소가 아닌 것

이 저장소는 다음이 아닙니다.

- 앱 프레임워크
- 런타임 플랫폼
- 서비스 템플릿 생성기
- 중앙 로그 저장소

서비스에 필요한:
- 앱 코드
- 로컬 트레이스
- 제품 UX
- 배포 로직

이런 것은 모두 각 서비스 저장소에 있어야 합니다.

### 핵심 동작 방식

구조는 단순합니다.

1. 작업이 intake로 들어옵니다.
2. 범위가 제한된 temporary link를 엽니다.
3. 실제 실행은 서비스 로컬에서 일어납니다.
4. review가 결과를 확인합니다.
5. 필수 스캔이 모두 있어야만 release가 가능합니다.

필수 스캔이 하나라도 없으면:
- link는 incomplete 상태이고
- release는 막힙니다

### 서비스가 맞춰야 하는 최소 구조

각 독립 서비스는 아래 정도의 작은 거버넌스 표면만 드러내면 됩니다.

- `README.md`
- `service.yaml`
- `governance/service.contract.json`
- `governance/dtp/`
- `governance/links/active/`
- `governance/evidence/`
- `governance/reviews/`
- `.gitignore`

그 외 구현 구조는 서비스가 자유롭게 가져갑니다.

### 저장소 구조

이 저장소는 의도적으로 작게 유지합니다.

- `control/`  
  거버넌스 계약과 레지스트리
- `policies/`  
  경계 규칙
- `schemas/`  
  검증 스키마
- `scripts/`  
  결정적 검증 및 트레이스 유틸
- `docs/`  
  사람이 읽는 공개 문서

### 검증 방법

```bash
bash scripts/validate_all.sh
```

이 스크립트는 다음을 확인합니다.

- 저장소 형태가 고정 규칙과 맞는지
- 계약 JSON이 유효한지
- 기준선 해시가 조용히 바뀌지 않았는지

### 공개 오픈소스 방향

이 저장소는 사람이 먼저 읽고 이해할 수 있어야 합니다.

목표는 다음입니다.

- 쉽게 읽히고
- 쉽게 검증되고
- 조용한 구조 드리프트가 어렵게 만드는 것

이 저장소는 제품 런타임이 아니라, 거버넌스 커널입니다.
