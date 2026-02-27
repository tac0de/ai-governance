# MCP

## Purpose
- 그룹 학습 세션 상태를 결정적으로 판정하고 다음 개입 정책을 제안한다.
- 카카오 챗봇 베타 그룹 시나리오에서 turn/participation 정책 경계를 고정한다.

## Owner
- Team: Platform Operations
- Contact: platform-ops-owner

## Runtime Boundary
- In scope: 세션 상태 평가, 개입 선택, 참여 정책 판정, trace 계약 이벤트 생성.
- Out of scope: 카카오 챗봇 런타임 직접 실행, 외부 네트워크 의존 verdict, 비결정적 점수 산출.
