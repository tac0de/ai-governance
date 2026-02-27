# RISK

## Security Risks
- Risk: 그룹 학습 세션 상태 판정 로직 우회.
- Control: high-tier MCP 경계 변경에 human gate 강제.

## Privacy Risks
- Risk: 학습 대화 원문이 증빙에 직접 유입.
- Control: hash-ref 중심 증빙과 최소 데이터 원칙 적용.

## Operational Risks
- Risk: 카카오 응답 제한(5초) 초과로 사용자 경험 저하.
- Control: `useCallback` 분기와 동기 타임박스(2.5s) 운영.

## Legal Risks
- Risk: 베타 전용 기능 제약 미확정 상태에서 오해된 배포.
- Control: 공개 문서 기반 가정 명시 + private evidence 수신 즉시 갱신.

## Approval Tier Mapping
- 일반 계약/문서 갱신: medium
- 신규 Core MCP 등록/경계 변경: high + human gate
