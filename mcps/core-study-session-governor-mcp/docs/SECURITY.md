# SECURITY

## Threat Model
- Threat: 세션 상태 조작으로 정책 우회 verdict 생성.
- Control: evidence hash 검증 + append-only trace 강제.

## Access Model
- `kakao-study-groupbot` 런타임 소유자만 호출 가능.
- allowlist capability 외 호출 금지.

## Data Handling
- verdict 경로는 요약/참조 데이터만 사용한다.
- 대화 원문 저장은 중앙 거버넌스 저장소 범위 밖으로 유지한다.

## Incident Response
- hash mismatch 또는 schema drift 발견 시 즉시 fail-closed.
- high tier human gate를 통과할 때까지 capability 확장 차단.
