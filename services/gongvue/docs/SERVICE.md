# SERVICE

## Purpose
- `gongvue` 서비스의 중앙 거버넌스 계약을 유지한다.
- 런타임 구현 대신 정책/검증/증빙 경계를 명확히 고정한다.

## Primary User
- 거버넌스 운영자
- `gongvue` 서비스 유지보수 담당자

## Boundaries
- In scope: 서비스 등록, 정책 프로파일, MCP allowlist, 계약 문서.
- Out of scope: `gongvue` 런타임 코드 변경, MCP 런타임 구현, 배포 인프라 자동화.

## Dependencies
- `control/registry/services.v0.1.json`
- `control/registry/mcps.v0.1.json`
- `scripts/validate_all.sh`

## Owner
- Team: Platform Operations
- Contact: architect-owner
