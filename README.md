# ai-governance v0.1

Deterministic Trace 기반 중앙 거버넌스 코어 저장소.

## Scope

- 중앙은 실행자가 아니라 판정자 역할만 수행
- 모든 상태/증거/계획은 hash ref로 참조
- 모든 행동은 고정 opcode 집합으로 실행
- 판정은 evidence + acceptance 기준으로 결정

## Repository Layout

- `schemas/`: envelope/trace/evidence/acceptance schema
- `specs/`: opcode set, trace rules
- `policies/`: policy profile, budget rules, and approval tier policy
- `benchmark/`: efficiency benchmark spec for market validation
- `fixtures/`: deterministic sample intent/evidence/acceptance/state
- `scripts/`: validator, dispatcher, trace runner, deterministic tests
- `traces/`: generated append-only trace artifacts

## Approval Tier Automation

- `low`: auto approval when required checks pass
- `medium`: policy review + human owner approval
- `high`: mandatory human gate

Policy file:
- `policies/approval_tier_policy.v0.1.json`

## Quick Start

```bash
bash scripts/validate_all.sh
bash scripts/run_intent.sh fixtures/intent.envelope.json traces/run1
bash scripts/test_determinism.sh
bash scripts/benchmark_gate.sh
```

## Legacy Archive

Current pre-rebuild implementation is archived in branch:
- `legacy/archive-2026-02-21`

## Overnight Automation

- Hourly governance progress workflow: `.github/workflows/overnight-governance-progress.yml`
