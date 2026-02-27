# SERVICE

## Purpose
- `kakao-study-groupbot`의 중앙 거버넌스 계약을 유지한다.
- 학생/자기개발 사용자 대상 그룹 학습 챗봇의 정책/검증/증빙 경계를 고정한다.

## Primary User
- 거버넌스 운영자
- `kakao-study-groupbot` 서비스 유지보수 담당자

## Boundaries
- In scope: 서비스 등록, 정책 프로파일, MCP allowlist, SLO 계약, 검증 아티팩트.
- Out of scope: 카카오 챗봇 런타임 코드, 실제 MCP 런타임 구현, 배포 인프라 자동화.

## Dependencies
- `control/registry/services.v0.1.json`
- `control/registry/mcps.v0.1.json`
- `schemas/bridge_intent.schema.json`
- `schemas/mcp_change_request.schema.json`
- `scripts/validate_all.sh`

## Owner
- Team: Platform Operations
- Contact: platform-ops-owner
