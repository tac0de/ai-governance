# Agent-Collab Independent Webgame Central Governance Plan v0.1

Version line: `v0.1`  
Date: `2026-02-25`  
Planning mode: `single macro gate + autopilot`

## 0) Planning Gate

- Objective:
  - 중앙 거버넌스 경로를 통해 독립 웹게임 서비스(가칭: `council-under-siege`)를 설계하고, 다중 에이전트 협업 산출물이 정책/증빙/추적 체계를 통과하도록 고정한다.
- Scope:
  - 서비스 목표/루프/역할 분담 계획서
  - 거버넌스 연계 계약(의도, 정책, 증빙, 트레이스) 정의
  - 승인 티어/리스크/차단 조건 정의
  - 단계별 산출물 및 검증 커맨드 정의
- Forbidden actions:
  - 본 저장소 내 게임 런타임/실서비스 코드 구현
  - 중앙 거버넌스 미연결 상태의 서비스 측 직접 실행/배포
  - 증빙/트레이스 누락 상태의 의사결정 반영
- Risk tier baseline:
  - `medium` (콘텐츠/경제/안전 정책 변경 시 `high`로 승격)
- Completion criteria:
  - 계획 문서 승인
  - 필수 산출물 템플릿 경로 확정
  - 검증/차단 규칙 확정
  - 첫 실행 사이클(의도 -> 정책검증 -> 증빙 -> 트레이스) 드라이런 가능 상태
- Rollback condition:
  - 결정 결과가 intent/policy/evidence/trace 링크를 하나라도 잃는 경우
  - 결정 경로에 비결정성(시간/랜덤/네트워크 의존)이 유입되는 경우
  - 승인 티어 대비 human gate 기록이 누락되는 경우

## 1) Service Vision (Unique Game)

- Service type: 독립 웹게임(런타임은 외부 서비스 저장소에서 구현)
- Core concept:
  - 플레이어는 "협업 평의회"의 한 명으로 참여한다.
  - 여러 전문 에이전트(전략, 내러티브, 밸런스, 안전)가 같은 턴에 제안을 제출한다.
  - 중앙 거버넌스가 정책/증빙 기반으로 제안을 검증하고 최종 액션을 확정한다.
  - 게임의 유니크 포인트는 "에이전트 간 합의 과정 자체"가 플레이 콘텐츠로 드러난다는 점이다.
- Player value:
  - 단순 결과 소비가 아니라 의사결정 과정을 읽고 개입하는 경험
  - 같은 목표를 다른 정책 조합으로 달성하는 리플레이 가치

## 2) Agent Collaboration Contract

- Required agent roles:
  - `producer-agent`: 목표/우선순위/릴리즈 조건 제안
  - `gameplay-agent`: 코어 루프/규칙 제안
  - `narrative-agent`: 이벤트/세계관 제안
  - `economy-agent`: 보상/난이도/인플레 리스크 제안
  - `safety-agent`: 안전/남용/정책 위반 가능성 평가
  - `qa-agent`: 테스트 시나리오/회귀 리스크 평가
- Turn contract:
  - Input: `intent_ref`, `policy_ref`, `evidence_ref[]`, `trace_ref_prev`
  - Output: `decision_id`, `selected_action`, `rejected_actions[]`, `verdict_hash`, `trace_ref_new`
- Determinism rule:
  - 같은 턴 입력과 같은 증빙이면 동일 `selected_action`과 동일 `verdict_hash`를 반환해야 한다.

## 3) Governance-Enforced Routing (Mandatory)

- Step 1:
  - 목표 정의를 `tmp/pm_objective_*.txt`로 고정
- Step 2:
  - 의도 계약을 `tmp/*.intent.local.json`으로 생성
- Step 3:
  - 필요한 MCP capability 변경은 `reports/governance/mcp-request-*.json`으로 요청
- Step 4:
  - 중앙 승인 후 registry/manifest/allowlist를 동시에 갱신
- Step 5:
  - trace append-only 기록과 hash 참조를 남기고 종료

## 4) Artifact Set (v0.1)

- Planning:
  - `reports/governance/council-under-siege-central-plan-v0.1.md`
- Objective:
  - `tmp/pm_objective_council_under_siege_phase1.txt`
- Intent:
  - `tmp/council-under-siege.phase1.intent.local.json`
- MCP requests:
  - `reports/governance/mcp-request-council-under-siege-<capability>-<date>.json`
- Decision and progress:
  - `reports/governance/council-under-siege-progress-<date>.md`

## 5) Release Phases

- Phase 1 (Governance Prototype):
  - 단일 턴 의사결정 루프를 거버넌스 경로로 검증
  - 성공 기준: trace/evidence 100% 링크, determinism test pass
- Phase 2 (Gameplay Expansion):
  - 턴 타입(전략/내러티브/경제) 확장
  - 성공 기준: 신규 capability 요청 모두 중앙 승인 기록 포함
- Phase 3 (Service Hardening):
  - SLO/실패복구/운영 런북 연계
  - 성공 기준: 릴리즈 게이트에서 `medium/high` 정책 위반 0건

## 6) Risk Matrix and Gate

- `medium`:
  - 일반 게임플레이 정책, 난이도 조정, 콘텐츠 분기
  - 필요 게이트: owner 승인 + 정책 검토 + acceptance 통과
- `high`:
  - 경제/결제/계정 영향, 안전정책 경계 변경, 대규모 보상정책 변경
  - 필요 게이트: human architect 승인 필수 + 명시적 rollback 조건
- Block conditions:
  - intent/policy/evidence/trace 중 하나라도 누락
  - registry/manifest/allowlist 동기화 불일치
  - determinism 검증 실패

## 7) Validation Commands

- `bash scripts/validate_all.sh`
- `bash scripts/test_determinism.sh`
- `bash scripts/bridge_one_shot_local.sh tmp/council-under-siege.phase1.intent.local.json`

## 8) 72-Hour Execution Checklist

- Day 1:
  - objective/intent 초안 고정
  - 초기 capability 목록과 risk tier 분류
- Day 2:
  - mcp-request 아티팩트 생성 및 중앙 검토 제출
  - acceptance fixture/trace 필드 점검
- Day 3:
  - 드라이런 실행
  - 결과 보고서와 다음 사이클 backlog 확정

## 9) Exit Criteria for v0.1

- 계획 범위 내 모든 실행 단위가 중앙 거버넌스 링크를 가진다.
- 승인 기록 없이 반영된 의사결정이 없다.
- 동일 입력/동일 증빙 재실행 시 동일 verdict를 재현한다.
- 고위험(`high`) 변경은 human architect 승인 흔적이 모두 남아 있다.
