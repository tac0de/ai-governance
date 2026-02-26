# RISK

## Security Risks
- Risk: 플러그인/사이드카 경계에서 정책 우회 실행.
- Control: high tier + human gate + 이벤트/훅 계약 고정.

## Privacy Risks
- Risk: 증빙에 고객 데이터 원문 유입.
- Control: 해시 참조 기반 요약 증빙만 허용.

## Operational Risks
- Risk: 서비스 레지스트리와 외부 레지스트리 드리프트.
- Control: `scripts/validate_cross_registry.sh`로 양측 정합성 강제.

## Legal Risks
- Risk: 고객 확장 코드로 규정 위반 동작 발생.
- Control: 확장 계약 문서, 요청-승인-증빙 경로 강제.

## Approval Tier Mapping
- 일반 온보딩: medium
- 확장 경계(플러그인 실행/사이드카 이벤트 계약): high + human gate
