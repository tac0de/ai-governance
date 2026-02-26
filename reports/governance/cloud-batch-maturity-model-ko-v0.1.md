# Cloud Batch 성숙도 모델 v0.1 (한국어)

목적: 대량 병렬 실행을 하더라도 중앙 거버넌스의 결정성/증빙/검증을 유지한다.

## L1 Core (현재 범위)
- 목표:
  - provider-agnostic 파일 계약 도입
  - `submit -> collect -> verify` 표준화
  - 필수 게이트(경로/해시/상태) 강제
- 산출물:
  - jobs/results/verdict 스키마
  - 샘플 fixture
  - `scripts/cloud_batch_submit.sh`
  - `scripts/cloud_batch_collect.sh`
  - `scripts/cloud_batch_verify.sh`
- 게이트:
  - Hybrid 모드
  - 필수 위반은 실패
  - 운영 지표는 경고

## L2 Adapter
- 목표:
  - Cloud Codex 또는 타 provider 어댑터 추가
  - submit/collect 내부 구현만 교체
- 원칙:
  - 외부 호출 방식은 바뀌어도 manifest 계약은 유지

## L3 Full Ops
- 목표:
  - 병렬 큐 운영(SLO, 재시도, 비용가드) 자동화
  - 실패 작업 자동 격리/재시도
- 원칙:
  - 중앙은 판정자
  - 실행 엔진은 교체 가능

## 운영 규칙
- 사람은 목표/범위/리스크/완료조건/롤백만 입력한다.
- 에이전트는 문서 생성, 실행 준비, 검증, 최종 보고를 수행한다.
- 모든 최종 반영은 `validate_all.sh` 통과가 전제다.
