# ai-governance v0.3

Deterministic Trace 기반 거버넌스 bootstrap compiler 저장소.

Release line: `v0.3` (artifact file line remains `v0.1` for schema and contract closure).

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
- JSON contract bundle, 레지스트리 정합성, 정책 프로파일, MCP allowlist/manifest, executor routing policy를 검증.

4. `.github/workflows/deterministic-governance.yml`
- CI에서 `validate_all.sh` + 결정성/벤치마크 게이트를 실행.

## One-Line Architecture

`control/templates` -> bootstrap scripts -> exportable contracts -> independent services

## Bootstrap Control Room

- Governance kernel: `policies/`, `schemas/`, `traces/`
- Bootstrap inputs: `control/registry/org.v0.1.json`, `control/registry/services.v0.1.json`, `control/templates/`
- Execution contracts: `control/registry/mcps.v0.1.json`, `control/mcps/`
- Seed / transition zone: `services/` (long-term runtime home is an independent service repo)

## Quick Start

```bash
bash scripts/validate_all.sh
bash scripts/validate_seed_catalog.sh
bash scripts/bootstrap_service.sh \
  --service-id example-service \
  --service-name "Example Service" \
  --output-dir /tmp/example-service
```

Legacy/Optional:
```bash
# DEPRECATED: cross-repo registry sync helper (governed-services)
bash scripts/validate_cross_registry.sh --mode auto
```

## Macro Planmode (Goal-Only Input)

```bash
# 1) Write one human goal
cat > traces/local/pm_objective_tdp_macro_v0_1.txt <<'TXT'
과금 UX 신뢰성 유지 조건에서 30일 운영 플랜을 확정한다.
TXT

# 2) Generate macro plan pack (Korean brief + minimal evidence JSON)
bash scripts/macro_plan_pack.sh thedivineparadox traces/local/pm_objective_tdp_macro_v0_1.txt high high true architect-owner

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

## New Service Bootstrap (Bootstrap-Only)

```bash
# 1) Validate the core compiler and archived seed catalog
bash scripts/validate_all.sh
bash scripts/validate_seed_catalog.sh

# 2) Generate an independent service repo scaffold
bash scripts/bootstrap_service.sh \
  --service-id alpha-service \
  --service-name "Alpha Service" \
  --bootstrap-profile standard \
  --risk-tier medium \
  --policy-profile balanced \
  --output-dir /tmp/alpha-service

# 3) Validate the generated portable governance kit
bash scripts/validate_bootstrap_output.sh /tmp/alpha-service

# 4) The generated repo can operate without ai-governance at runtime
```

- 확장 기본모델은 `Plugin + Sidecar`로 고정한다.
- 코어 엔진은 Docker 내부 비공개(`opaque`)로 유지한다.
- 경계 변경은 `high` + human gate를 요구한다.
- 중앙 저장소는 지속 운영자가 아니라 초기 설계/정렬 역할에 머문다.
- `services/`는 archived seed example zone이며, 장기 운영 위치가 아니다.

## Seed Catalog

- `control/registry/services.v0.1.json`는 active service registry가 아니라 archived seed catalog다.
- `services/thedivineparadox/`는 `ritual-uiux` bootstrap profile 대표 seed example이다.
- `services/gongvue/`, `services/obsidian-mcp/`, `services/personal-webnovel/`는 legacy minimal seed examples이다.
- Seed examples는 `bash scripts/validate_seed_catalog.sh`로 별도 검증한다.

## PM <-> Executor Bridge (Deterministic Queue)

Optional reusable governance lane for services that want to keep the bridge format.

```bash
# 1) PM intent submit
bash scripts/bridge_submit.sh fixtures/bridge/pm_intent.sample.json

# 2) Optional human gate (required when status=awaiting_human_gate)
bash scripts/bridge_human_gate.sh phase2-backend-fastify-ts approve architect-owner

# 3) Dispatch ready intents to executor packets
bash scripts/bridge_dispatch.sh

# 4) Consume dispatched packets into local executor task queue (traces/)
bash scripts/bridge_consume.sh --executor service-review

# Optional: alternate governance lanes
bash scripts/bridge_consume.sh --executor policy-ops
bash scripts/bridge_consume.sh --executor governance-council

# 5) One-shot minimal-token mode (local PM + bridge pipeline)
bash scripts/bridge_one_shot_local.sh tdp.phase2.ops_hardening traces/local/pm_objective_ops_hardening.txt high true architect-owner
```

## Local PM Integration (No External API)

```bash
# 1) Prepare objective text (free-form)
cat > traces/local/pm_objective.txt <<'TXT'
Plan and package a high-tier backend architecture migration with deterministic safeguards.
TXT

# 2) Generate PM intent JSON locally and auto-submit/dispatch
bash scripts/bridge_local_pm.sh tdp.phase2.backend_fastify_ts_strict traces/local/pm_objective.txt traces/local/pm_intent.local.json high true --auto
```

Notes:
- If generated intent is `high` tier or `human_gate_required=true`, dispatch is held (`awaiting_human_gate`) until:
  - `bash scripts/bridge_human_gate.sh <intent_id> approve <actor>`

## Governance Journal Export

```bash
# Prepare a deterministic export packet for the external Obsidian governance diary
bash scripts/export_governance_journal.sh traces/bridge
```

This creates a local export packet and receipt skeleton under `traces/governance-journal/`.

## Appendix (Secondary Paths)

- `control/templates/`: service bootstrap JSON contract templates
- `control/playbooks/`: incident/change/onboarding JSON playbooks
- `control/agents/`: central department assignment catalog
- `control/prompts/`: generic governance prompt library
- `control/specs/`: opcode set, JSON trace rules
- `control/benchmarks/`: efficiency benchmark spec
- `fixtures/`: deterministic sample inputs
- `docs/`: GitHub Pages showcase only
- `traces/`: the only runtime scratch + governance diary space
- `services/`: seed contracts and transition examples, not the mandatory long-term runtime home

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
