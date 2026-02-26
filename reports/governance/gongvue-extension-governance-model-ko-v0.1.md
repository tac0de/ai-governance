# Gongvue Docker 확장 거버넌스 모델 v0.1 (KO)

## 1) 목적
- `gongvue`를 고객사에 Docker 이미지로 전달하되, 코어 소스는 비공개(opaque)로 유지한다.
- 고객사 커스터마이징은 Plugin/Sidecar 경계에서만 허용한다.
- 중앙 거버넌스는 정책/승인/검증/감사를 담당하고, 런타임 구현은 서비스 저장소에서 수행한다.

## 2) 배포 원칙 (코어 비공개)
- 배포 모드: `docker_image`
- 코어 가시성: `opaque`
- 고객사 변경 허용 영역:
  - Plugin 마운트 경로
  - Sidecar 웹훅/API 연동 경로
- 코어 엔진 파일/모듈 직접 수정은 금지한다.

## 3) Plugin 확장 계약
- 기본 마운트: `/opt/gongvue/plugins`
- 실행 시점: 사전 정의된 훅 지점(예: 지도 클릭, 경보 이벤트)
- 입력 계약:
  - `event_id`
  - `event_type`
  - `trace_ref`
  - `payload_ref`
- 출력 계약:
  - 허용된 액션 객체 배열
  - 정책 판정(`allow`/`deny`)
- 필수 제어:
  - 실행 시간 제한
  - 리소스 제한(CPU/메모리)
  - 파일 접근 범위 제한
  - 코어 모듈 직접 접근 금지

## 4) Sidecar 확장 계약
- 목적: 고객사 로직을 별도 컨테이너로 분리해 보안 경계를 유지한다.
- 이벤트 송신 필수 필드:
  - `event_id`
  - `event_type`
  - `trace_ref`
  - `payload_ref`
  - `idempotency_key`
- 보안 규칙:
  - 서명 기반 인증(HMAC 등)
  - timeout/retry 고정
  - 멱등성 키 기반 중복 처리
- 중앙 정책:
  - Sidecar 경계 변경은 기본 `high` + human gate

## 5) 고객사/중앙 책임 경계
- 고객사:
  - Plugin/Sidecar 코드 품질과 기능 책임
  - 계약 준수(입출력/보안/리소스 제한) 책임
- 중앙 거버넌스:
  - 요청 승인(티어/게이트)
  - 증빙 해시 검증
  - 정책 위반 시 차단/롤백 절차 집행

## 6) 승인 티어 기준
- 일반 서비스 온보딩: `medium`
- Plugin 실행 정책/훅 경계 변경: `high` + human gate
- Sidecar 이벤트 계약/보안 제어 변경: `high` + human gate
