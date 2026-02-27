# ai-governance v0.1

Deterministic Trace 기반 중앙 거버넌스 코어 저장소.

## Start Here (Core 4)

1. `control/registry/`
- 조직/서비스/MCP의 단일 진실 소스.

2. `schemas/` (특히 중앙 통제 스키마)
- `org.schema.json`
- `services_registry.schema.json`
- `mcps_registry.schema.json`
- `mcp_allowlist.schema.json`
- `mcp_manifest.schema.json`

3. `scripts/validate_all.sh`
- 중앙 설계 강제 지점.
- 고정 문서 세트, 레지스트리 정합성, 정책 프로파일, MCP allowlist/manifest, executor routing policy를 검증.

4. `.github/workflows/deterministic-governance.yml`
- CI에서 `validate_all.sh` + 결정성/벤치마크 게이트를 실행.

## One-Line Architecture

`control/registry` -> `scripts/validate_all.sh` -> CI workflow -> `traces`

## Central Control Room

- Government: `policies/`, `schemas/`, `traces/`
- Company: `control/registry/org.v0.1.json`, `control/registry/services.v0.1.json`, `services/`
- Execution contracts: `control/registry/mcps.v0.1.json`, `mcps/`
- Executor routing: `policies/agent_routing_policy.v0.1.json`

## Quick Start

```bash
bash scripts/validate_all.sh
bash scripts/run_intent.sh fixtures/intent.envelope.json traces/run1
bash scripts/test_determinism.sh
bash scripts/benchmark_gate.sh
```

Legacy/Optional:
```bash
# DEPRECATED: cross-repo registry sync helper (governed-services)
bash scripts/validate_cross_registry.sh --mode auto
```

## Macro Planmode (Goal-Only Input)

```bash
# 1) Write one human goal
cat > tmp/pm_objective_tdp_macro_v0_1.txt <<'TXT'
과금 UX 신뢰성 유지 조건에서 30일 운영 플랜을 확정한다.
TXT

# 2) Generate macro plan pack (Korean brief + minimal evidence JSON)
bash scripts/macro_plan_pack.sh thedivineparadox tmp/pm_objective_tdp_macro_v0_1.txt high high true architect-owner

# 3) Run governance validation
bash scripts/validate_all.sh
```

## Cloud Batch L1 Core (Provider-Agnostic)

```bash
# 1) Submit jobs manifest into deterministic trace batch folder
bash scripts/cloud_batch_submit.sh \
  --service thedivineparadox \
  --jobs-manifest fixtures/cloud_batch/jobs.sample.v0.1.json \
  --run-id tdp.batch.sample.v0_1 \
  --provider manifest

# 2) Collect results manifest (from provider output or local fixture)
bash scripts/cloud_batch_collect.sh \
  --run-id tdp.batch.sample.v0_1 \
  --provider manifest \
  --results-manifest fixtures/cloud_batch/results.sample.v0.1.json

# 3) Verify artifacts and hash integrity
bash scripts/cloud_batch_verify.sh \
  --run-id tdp.batch.sample.v0_1 \
  --service thedivineparadox \
  --strictness hybrid

# Optional: force a specific policy file
bash scripts/cloud_batch_verify.sh \
  --run-id tdp.batch.sample.v0_1 \
  --policy-file policies/cloud_batch_policy.v0.1.json

# 4) Final governance validation gate
bash scripts/validate_all.sh
```

## 신규 서비스 온보딩 (Contracts-Only)

```bash
# 1) 서비스 계약 패키지 추가 (services/<service-id>)
# 2) 중앙 레지스트리에 등록 (control/registry/services.v0.1.json)
# 3) 중앙 계약 검증
bash scripts/validate_all.sh
```

- 확장 기본모델은 `Plugin + Sidecar`로 고정한다.
- 코어 엔진은 Docker 내부 비공개(`opaque`)로 유지한다.
- 경계 변경은 `high` + human gate를 요구한다.

## PM <-> Executor Bridge (Deterministic Queue)

```bash
# 1) PM intent submit
bash scripts/bridge_submit.sh fixtures/bridge/pm_intent.sample.json

# 2) Optional human gate (required when status=awaiting_human_gate)
bash scripts/bridge_human_gate.sh phase2-backend-fastify-ts approve architect-owner

# 3) Dispatch ready intents to executor packets
bash scripts/bridge_dispatch.sh

# 4) Consume dispatched packets into local executor task queue (tmp/)
bash scripts/bridge_consume.sh --executor codex

# Optional: multi-executor queue
bash scripts/bridge_consume.sh --executor gemini-flash
bash scripts/bridge_consume.sh --executor claude-sonnet

# 5) One-shot minimal-token mode (local PM + bridge pipeline)
bash scripts/bridge_one_shot_local.sh tdp.phase2.ops_hardening tmp/pm_objective_ops_hardening.txt high true architect-owner
```

## Local Codex PM Integration (No External API)

```bash
# 1) Prepare objective text (free-form)
cat > tmp/pm_objective.txt <<'TXT'
Plan and package a high-tier backend architecture migration with deterministic safeguards.
TXT

# 2) Generate PM intent JSON locally and auto-submit/dispatch
bash scripts/bridge_local_pm.sh tdp.phase2.backend_fastify_ts_strict tmp/pm_objective.txt tmp/pm_intent.local.json high true --auto
```

Notes:
- If generated intent is `high` tier or `human_gate_required=true`, dispatch is held (`awaiting_human_gate`) until:
  - `bash scripts/bridge_human_gate.sh <intent_id> approve <actor>`

## Appendix (Secondary Paths)

- `control/templates/`: service/MCP fixed-doc templates
- `control/playbooks/`: incident/change/onboarding guides
- `control/specs/`: opcode set, trace rules
- `control/benchmarks/`: efficiency benchmark spec
- `fixtures/`: deterministic sample inputs
- `docs/`: GitHub Pages showcase only
- `traces/`: local deterministic traces only (long-lived service logs should move to `obsidian-mcp`)

## Legacy Archive

Current pre-rebuild implementation is archived in branch:
- `legacy/archive-2026-02-21`

## GitHub Pages Showcase

- Multilingual showcase site source: `docs/index.html`
- Assets: `docs/assets/site.css`, `docs/assets/site.js`
- Favicon: `docs/favicon.ico`
- Default language: browser locale auto-detect (`navigator.languages`/`navigator.language`), then stored preference
- Public contact: `wonyoungchoiseoul@gmail.com`
- Deploy workflow: `.github/workflows/github-pages-showcase.yml`
