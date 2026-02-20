# 70. DTP Protocol Principles

## 목적
DTP를 "새 언어"가 아니라 "불변 프로토콜"로 고정한다.

## 핵심 원칙
- DTP는 프로토콜(약속)이다.
- 모델/에이전트/언어는 교체 가능한 부품이다.
- 코어는 규칙, 경계, 기록 구조를 중심으로 고정한다.

## 왜 이 구조가 유리한가
- 멀티모델 대응: OpenAI 외 다른 모델도 어댑터만 교체하면 연결 가능.
- 멀티언어 대응: TS/Python/Go/Rust 등 구현 언어와 분리 가능.
- 장기 유지보수: 새 언어 설계 없이도 생태계와 도구를 활용 가능.

## 불변 3요소
1. Trace event schema 고정  
   - canonical fields: `traceId`, `parentId`, `layer`, `intent`, `policy`, `action`, `inputsHash`, `outputsHash`, `timestamp`, `signature?`
2. Boundary/authority rule 고정  
   - 분석 레이어는 실행 직접 호출 금지
   - 실행 레이어는 정책 토큰/권한 없으면 거부
3. Integrity model 고정  
   - append-only
   - hash chain(`prevHash`, `recordHash`)
   - deterministic replay

## 구현 경계
- `ai-governance`: 프로토콜/정책/계약 관리
- `engine`: 어댑터 구현 + 실행 + replay
- `services`: 도메인 기능 제공(프로토콜 준수)

## 감사 기준(간단 체크)
- 코어 코드에 모델 특화 프롬프트 없음
- 상위 레이어에서 provider raw error를 직접 분기하지 않음
- replay에서 동일 입력 해시로 동일 결과/실패 코드 재현 가능
