# ai-governance v0.1

Deterministic Trace 기반 중앙 거버넌스 코어 저장소.

## Start Here (Core 4)

1. `control/registry/`
- 조직/서비스/MCP의 단일 진실 소스.

2. `schemas/` (특히 중앙 통제 스키마 5개)
- `org.schema.json`
- `services_registry.schema.json`
- `mcps_registry.schema.json`
- `mcp_allowlist.schema.json`
- `mcp_manifest.schema.json`

3. `scripts/validate_all.sh`
- 중앙 설계 강제 지점.
- 고정 문서 세트, 레지스트리 정합성, 정책 프로파일, MCP allowlist/manifest를 검증.

4. `.github/workflows/deterministic-governance.yml`
- CI에서 `validate_all.sh` + 결정성/벤치마크 게이트를 실행.

## One-Line Architecture

`control/registry` -> `scripts/validate_all.sh` -> CI workflow -> `traces`

## Central Control Room

- Government: `policies/`, `schemas/`, `traces/`
- Company: `control/registry/org.v0.1.json`, `control/registry/services.v0.1.json`, `services/`
- Execution: `control/registry/mcps.v0.1.json`, `mcps/`

## Quick Start

```bash
bash scripts/validate_all.sh
bash scripts/run_intent.sh fixtures/intent.envelope.json traces/run1
bash scripts/test_determinism.sh
bash scripts/benchmark_gate.sh
```

## Appendix (Secondary Paths)

- `control/templates/`: service/MCP fixed-doc templates
- `control/playbooks/`: incident/change/onboarding guides
- `specs/`: opcode set, trace rules
- `fixtures/`: deterministic sample inputs
- `benchmark/`: efficiency benchmark spec
- `docs/`: archived or supporting docs

## Legacy Archive

Current pre-rebuild implementation is archived in branch:
- `legacy/archive-2026-02-21`

## Overnight Automation

- Hourly governance progress workflow: `.github/workflows/overnight-governance-progress.yml`
