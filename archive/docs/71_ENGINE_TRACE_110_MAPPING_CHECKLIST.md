# 71. Engine Trace 1.1.0 Mapping Checklist

## 목적
`contracts/trace.schema.json` v1.1.0 필드가 engine 실행 경로에서 빠짐없이 매핑되는지 점검한다.

## 범위
- 대상 레포: `kernel-engine`
- 대상 유형:
  - runtime trace emit 지점
  - replay/trace 생성 스크립트
  - append-only 저장 지점

## 기준 계약
- `contracts/trace.schema.json` (v1.1.0)

## 필드 매핑 체크(필수)
- [ ] `traceId`
- [ ] `timestamp`
- [ ] `level`
- [ ] `message`

## 필드 매핑 체크(권고)
- [ ] `parentId`
- [ ] `layer`
- [ ] `intent`
- [ ] `policy`
- [ ] `action`
- [ ] `inputsHash`
- [ ] `outputsHash`
- [ ] `prevHash`
- [ ] `recordHash`
- [ ] `signature` (옵션)

## 경계/권한 체크
- [ ] 코어 레이어에 모델 특화 프롬프트 로직 없음
- [ ] 코어 레이어에 모델 raw 출력 포맷 분기 없음
- [ ] 실행 레이어는 정책/권한 토큰 없으면 거부
- [ ] 상위 레이어는 normalized failure code만 처리

## 무결성/재현 체크
- [ ] 저장 방식 append-only
- [ ] hash chain 검증 가능 (`prevHash` -> `recordHash`)
- [ ] 동일 입력 해시 기준 replay 재현 가능

## 1차 스캔 참조 경로 (2026-02-19)
- `kernel-engine/docs/MCP_SUB_AGENT_RUNBOOK.md` (deterministic trace fields 언급)
- `kernel-engine/tools/scripts/tac0de_cascade.py` (`trace` artifact 생성)
- `kernel-engine/tools/scripts/tac0de_demo.sh` (`.ops/tac0de_trace.json` 생성)
- `kernel-engine/packages/core/codex-engine/src/storage/abilityRepository.ts` (append 계열 저장)

## 완료 조건
- 체크리스트 항목 증적(파일 경로 + 커밋 SHA + 샘플 trace) 확보
- 미충족 항목은 `gap list`로 분리 후 우선순위 지정
