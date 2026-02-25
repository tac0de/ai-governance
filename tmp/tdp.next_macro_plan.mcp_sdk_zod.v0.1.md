# TheDivineParadox Next Macro Plan v0.1

Scope: 다음 단계는 `TDP 제품 고도화`와 `중앙 거버넌스 강제 경유`를 동시에 만족해야 한다.

## 0) Fixed Decisions

- 중앙 거버넌스(`ai-governance`)는 계약/검증/승인만 담당한다.
- 실제 MCP 서버 구현은 서비스 런타임 또는 별도 실행 저장소에서 수행한다.
- 서비스는 MCP ID를 새로 만들지 않는다. `core-*`만 사용한다.
- MCP 추가/변경은 `request artifact -> 중앙 검증 -> 승인 반영 -> 서비스 동기화` 4단계를 강제한다.

## 1) Strategic Goal

- UX: 첫 3초 단일 행동 구조 유지 + 반복 참여 루프 강화
- Learning: 유의미한 행동 패턴 수집/학습 액션 자동 제안
- MCP: 실제 동작 가능한 툴 체계(`@modelcontextprotocol/sdk`, `zod`)로 전환

## 2) MCP Tool Creation Standard (Real Implementation Baseline)

다음 기준을 만족할 때만 “새 MCP capability”를 요청한다.

### 2.1 Create vs Reuse Decision

- Reuse:
  - 기존 `core-*` capability의 입력 스키마 확장만으로 해결 가능
  - 위험등급/권한 경계가 동일
- Create:
  - 새로운 외부 시스템 접근이 필요
  - 기존 capability로는 trace 필드/결정 근거를 보존할 수 없음
  - 위험등급이 상향되어 별도 human gate 정책이 필요한 경우

### 2.2 Required Runtime Stack

- Node.js 20+
- `@modelcontextprotocol/sdk`
- `zod`
- `zod-to-json-schema` (schema export용)

### 2.3 Minimal Runtime Contract (per capability)

- `inputSchema`: zod 정의 + json schema export
- `outputSchema`: zod 정의 + json schema export
- `deterministicMode`: 기본 `true`
- `timeoutMs`: 고정값
- `traceFields`: `tool_name`, `tool_version`, `input_hash`, `output_hash`, `latency_ms`, `risk_tier`
- `errorShape`: `{ code, message, retryable }` 고정

### 2.4 Governance Artifact Set (must exist)

- `control/registry/mcps.v0.1.json` (ID/owner/risk 등록)
- `mcps/core-*/manifest.json` (capability 계약)
- `mcps/core-*/versions/runtime.binding.v0.1.json` (실행 산출물/해시 고정)
- `services/thedivineparadox/mcp.allowlist.json` (서비스 허용치)
- `reports/governance/mcp-request-<slug>-<yyyymmdd>.json` (승인 근거)

## 3) Proposed MCP Roadmap for TDP (Core-Named)

서비스 특화 이름 대신 범용 코어 네이밍으로 제안한다.

1. `core-signal-analytics`
- 목적: 이벤트/KPI 요약 읽기, 임계치 기반 액션 후보 산출
- 위험도: low/medium
- TDP 효과: 학습 루프 자동화 근거 생성

2. `core-evidence-fetch`
- 목적: 허용 도메인에서 외부 근거 수집(allowlist 강제)
- 위험도: medium/high
- TDP 효과: “자가발전” 근거 데이터 확장

3. `core-safety-fallback`
- 목적: LLM 실패 시 정책 기반 fallback 선언/응답 생성
- 위험도: high
- TDP 효과: 장애 시 일관성 유지, human gate 연계

## 4) Execution Tracks (No Time Estimate)

## Track A — UX/Product Loop (TDP)

- 목표: 질문 -> 행동 -> 보상 -> 다음 행동의 1회전 완성도 상승
- 산출물:
  - 첫 화면 One CTA 강제
  - 결과 화면 next action 1개 고정
  - 이벤트 2개(`cta_focus_seen`, `result_next_action_click`) 운영 지표 연결
- 완료 조건:
  - 신규 이벤트가 `/kpi-summary` 계산에 반영
  - 첫 interaction ambiguity 없음

## Track B — Real MCP Runtime (Service/Runtime Repo)

- 목표: 문서형 MCP가 아닌 “실행 가능한 MCP 서버” 1개 이상
- 산출물:
  - `@modelcontextprotocol/sdk` 기반 tool server
  - `zod` 입력/출력 검증
  - deterministic trace 해시 출력
- 완료 조건:
  - 로컬 호출 + 통합 테스트 + trace evidence 생성

## Track C — Governance Enforcement (ai-governance)

- 목표: 중앙 승인 없이는 capability drift 불가
- 산출물:
  - MCP request schema 검증 강화
  - `validate_all.sh`에 request artifact gate 추가
  - high-risk 자동 `human_gate_required=true` 규칙 검증
- 완료 조건:
  - 비승인 capability 변경 시 검증 실패

## 5) Concrete File Targets

## 5.1 ai-governance

- `schemas/mcp_change_request.schema.json`
- `scripts/validate_all.sh`
- `control/registry/mcps.v0.1.json`
- `services/thedivineparadox/mcp.allowlist.json`
- `reports/governance/mcp-request-*.json`

## 5.2 thedivineparadox

- `apps/backend/config/mcp.allowlist.v0.1.json`
- `scripts/mcp_request_emit.sh`
- `tmp/mcp.request.<slug>.intent.json`
- `tmp/mcp.request.<slug>.request.json`
- MCP runtime 구현용 별도 디렉터리(예: `apps/mcp-runtime/*`)

## 6) Validation Commands

- Governance:
  - `bash /Users/wonyoung_choi/ai-governance/scripts/validate_all.sh`
- TDP backend:
  - `npm --prefix /Users/wonyoung_choi/projects/thedivineparadox/apps/backend run lint`
  - `npm --prefix /Users/wonyoung_choi/projects/thedivineparadox/apps/backend run test:unit`
  - `npm --prefix /Users/wonyoung_choi/projects/thedivineparadox/apps/backend run test:integration`
- MCP runtime (new):
  - `npm --prefix /Users/wonyoung_choi/projects/thedivineparadox/apps/mcp-runtime run lint`
  - `npm --prefix /Users/wonyoung_choi/projects/thedivineparadox/apps/mcp-runtime run test`

## 7) Human Gate Matrix

- `high`:
  - 신규 외부 데이터 소스 접근
  - 신규 MCP ID 발급 요청
  - 권한 범위 확대(write/action)
- `medium`:
  - capability 입력 스키마 확장
  - timeout/retry 정책 변경
- `low`:
  - 문서/테스트/리플레이 fixture 추가

## 8) Report Output Format (for all runs)

1. WHAT I DID
2. WHERE IT IS RUNNING
3. HUMAN REQUIRED (links + paths)
4. RISK / UNKNOWN
