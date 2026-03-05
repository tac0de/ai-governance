# ai-governance Architecture Map for v0.7.4

## 목적

이 문서는 `ai-governance` 전체 구조를 기준으로,
`v0.7.4` 작업을 어디서부터 어떻게 진행할지 파일 단위로 고정한다.

핵심 목표:
- `v1.0`부터 B2B 상용 거버넌스 솔루션으로 수익화 가능한 형태 준비
- 경계 봉인(`/governance/**`) + 승인 게이트 + 감사 추적(DTP) 일관성 강화

## 현재 아키텍처 (v0.7)

1. Policy Boundary Layer
- 파일: `policies/external_execution_boundary.v0.7.json`
- 역할: 중앙 거버넌스가 할 수 있는 일/금지되는 일, 언어 정책, 런타임 소유권 경계 정의

2. Contract Registry Layer
- 파일: `control/registry/*.v0.7.json`
- 역할: 서비스 커널, 링크 스캔 포인트, 임시 링크 수명주기, 모니터링, 릴리즈 준비/승격 정책 정의

3. Trace Rule Layer (DTP)
- 파일: `control/specs/trace_rules.v0.7.json`
- 역할: append-only trace, hash chain, validator receipt 규칙 고정

4. Schema Validation Layer
- 파일: `schemas/*.schema.json`
- 역할: 계약 JSON 구조를 정적 검증

5. Enforcement Layer
- 파일: `scripts/validate_all.sh`, `scripts/scan_repo_hygiene.sh`, `scripts/trace_append.sh`
- 역할: 고정 파일셋/고정 구조/핵심 필드/해시 기반 결정적 검증

6. Delivery Layer
- 파일: `.github/workflows/deterministic-governance.yml`
- 역할: PR/메인 브랜치 코어 계약 검증 강제

## 0.7.4 6단계 플로우 매핑 (현재 대비)

1. Intake / Contracting
- 현재 매핑: `temporary-links`의 `request` 단계, `link-scan-points`의 `intake-scan`
- 갭: 정책 번들(policy bundle) 고정 산출물이 계약상 명시적이지 않음

2. Link (Boundary Seal)
- 현재 매핑: `service-kernel` + `temporary-links.kit_structure`
- 갭: `/governance/VERSION`, `/governance/policies/**`, `/governance/bin/**` 경계 봉인 항목이 커널 필수 목록에 미포함

3. Baseline Scan (DTP 시작)
- 현재 매핑: `service.snapshot.json`, `hygiene.report.json`, trace append 규칙
- 갭: 의존성/빌드/테스트/Lighthouse/보안 스캔의 "baseline packet" 계약이 별도 고정 안됨

4. Plan (Agent-assisted Structured)
- 현재 매핑: `orchestration/execution.plan.md` (문서형)
- 갭: `/governance/plan.json` 스키마+allowlist 기반 실행 플랜 계약 부재

5. Review / Gate
- 현재 매핑: `launch-readiness`, `version-promotion`
- 갭: "승인 전 apply 금지"를 plan 상태와 직접 연동한 규칙이 명시적이지 않음

6. Apply / Release + Monitoring
- 현재 매핑: `pre-release-scan` + `monitoring-clear` + DTP receipt
- 갭: `gov apply`의 경계 강제(`/governance/** only`)를 명시한 실행 계약이 중앙 규칙으로 고정되지 않음

## 아키텍처 강점

- 중앙/서비스 런타임 소유권 경계가 이미 강하게 선언되어 있음
- DTP append-only + hash-chain + validator receipt 체계가 명확함
- release readiness와 version promotion이 분리되어 정책 계층이 명료함
- CI 검증이 간단하고 결정적이라 drift 감지가 빠름

## 아키텍처 리스크

- 검증 스크립트가 고정 카운트/고정 파일셋에 강하게 결합되어 확장 비용이 큼
- plan이 문서형(`.md`) 중심이라 자동승인/자동실행 연계가 약함
- baseline 스캔 항목이 분산되어 있어 B2B 온보딩 시 설명 비용이 큼

## 0.7.4 실행 순서 (권장)

Phase A. 계약 정렬 (호환 우선)
- `temporary-links`와 `link-scan-points` 용어를 6단계 기준으로 정렬
- 기존 필드 삭제보다 alias/추가 방식 우선으로 호환성 유지

Phase B. 경계 봉인 강화
- `service-kernel`에 경계 봉인 필수 엔트리 추가:
  - `governance/VERSION`
  - `governance/policies`
  - `governance/bin`
- 관련 스키마/검증식 동시 갱신

Phase C. Baseline/Plan 계약 추가
- baseline packet 계약과 `governance/plan.json` 계약을 중앙 스키마로 승격
- allowlist와 approval 상태를 필수로 강제

Phase D. Gate/Apply 강제
- "approval 없으면 apply 불가" + "경계 밖 경로 변경 시 차단" 규칙을 검증 스크립트에 반영
- pre-release scan 항목과 launch-readiness 체크를 연결 강화

Phase E. 상용화 신호 체계
- version-promotion에 B2B 증빙(유료 사용, SLA, 컴플라이언스 감사 흔적) 확장
- `v1.x commercial-ready` 판정 체크리스트를 정책화

## 즉시 실행 백로그 (파일 단위)

1. Registry
- `control/registry/service-kernel.v0.7.json`
- `control/registry/link-scan-points.v0.7.json`
- `control/registry/temporary-links.v0.7.json`
- `control/registry/launch-readiness.v0.7.json`
- `control/registry/version-promotion.v0.7.json`

2. Schemas
- `schemas/service_kernel.schema.json`
- `schemas/link_scan_points.schema.json`
- `schemas/launch_readiness.schema.json`
- `schemas/version_promotion_policy.schema.json`
- (신규 필요 시) `schemas/governance_plan.schema.json`

3. Enforcement
- `scripts/validate_all.sh`
- `scripts/scan_repo_hygiene.sh`

4. Docs
- `docs/solutionization-flow.v0.7.4.md`
- `docs/service-bootstrap.md`
- `README.md`

## 결정 원칙

- 원칙 1: 중앙은 계약/검증/게이트만 소유, 런타임은 서비스가 소유
- 원칙 2: 경계 위반은 즉시 차단
- 원칙 3: 승인 없는 변경은 적용 불가
- 원칙 4: release 판단은 반드시 증빙 해시와 연결
- 원칙 5: 확장은 가능하되 기존 `v0.7` 계약 파손은 단계적으로만 허용
