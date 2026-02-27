# RUNBOOK

## Routine Validation
- `bash scripts/validate_all.sh`
- `bash scripts/test_determinism.sh`
- (Optional/Deprecated) `bash scripts/validate_cross_registry.sh --mode auto`

## Onboarding Flow
- 중앙 레지스트리에 서비스 계약 패키지를 등록한다.
- MCP 확장 요청은 `reports/governance/mcp-request-*.json`로 생성한다.

## Change Flow
- medium 범위: 계약/문서 정리 후 검증 통과 시 반영
- high 범위: human gate 승인 후 반영

## Incident Handling
- 해시 불일치: 즉시 반영 중단 후 증빙 재생성
- 요청/allowlist 불일치: 요청 상태를 `requested`로 롤백하고 재검토
