#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 || $# -gt 6 ]]; then
  echo "Usage: $0 <service_slug> <goal_txt_path> [risk_tier] [approval_tier] [human_gate_required] [owner]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
service_slug="$1"
goal_path="$2"
risk_tier="${3:-medium}"
approval_tier="${4:-medium}"
human_gate_required="${5:-false}"
owner="${6:-architect-owner}"

if [[ ! "$service_slug" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "INVALID_SERVICE_SLUG ${service_slug}" >&2
  exit 1
fi
if [[ ! -f "$goal_path" ]]; then
  echo "GOAL_FILE_MISSING ${goal_path}" >&2
  exit 1
fi
if [[ "$risk_tier" != "low" && "$risk_tier" != "medium" && "$risk_tier" != "high" ]]; then
  echo "INVALID_RISK_TIER ${risk_tier}" >&2
  exit 1
fi
if [[ "$approval_tier" != "low" && "$approval_tier" != "medium" && "$approval_tier" != "high" ]]; then
  echo "INVALID_APPROVAL_TIER ${approval_tier}" >&2
  exit 1
fi
if [[ "$human_gate_required" != "true" && "$human_gate_required" != "false" ]]; then
  echo "INVALID_HUMAN_GATE_REQUIRED ${human_gate_required}" >&2
  exit 1
fi

tmp_goal_rel="tmp/pm_objective_${service_slug//-/_}_macro_v0_1.txt"
tmp_intent_rel="tmp/${service_slug}.macro.v0_1.intent.local.json"
brief_rel="traces/governance/${service_slug}-macro-planmode-brief-v0.1.ko.md"
evidence_rel="traces/governance/${service_slug}-macro-planmode-evidence-min-v0.1.json"

mkdir -p "$ROOT_DIR/tmp" "$ROOT_DIR/traces/governance"
goal_abs="$(cd "$(dirname "$goal_path")" && pwd)/$(basename "$goal_path")"
target_goal_abs="$ROOT_DIR/$tmp_goal_rel"
if [[ "$goal_abs" != "$target_goal_abs" ]]; then
  cp "$goal_path" "$target_goal_abs"
fi

cat > "$ROOT_DIR/$tmp_intent_rel" <<EOF
{
  "intent_id": "${service_slug}.macro.v0_1",
  "objective": "Execute macro-planmode cycle for ${service_slug} using governance-enforced path.",
  "constraints": [
    "Keep deterministic verdict path.",
    "Keep append-only trace with hash-linked evidence.",
    "No product runtime implementation in ai-governance."
  ],
  "approval_tier": "${approval_tier}",
  "human_gate_required": ${human_gate_required},
  "target_executor": "codex",
  "evidence_refs": []
}
EOF

cat > "$ROOT_DIR/$brief_rel" <<EOF
# ${service_slug} 거시 플랜모드 브리프 v0.1

## 1) 목표(사람이 입력)
$(cat "$ROOT_DIR/$tmp_goal_rel")

## 2) 범위(이번 사이클)
- 범위 내 작업만 수행
- 범위 외 변경은 중단 후 human gate 요청

## 3) 금지사항
- ai-governance에 서비스 런타임 구현 금지
- 결정 경로에 wall-clock/random/network 의존 금지

## 4) 리스크/승인
- risk_tier: \`${risk_tier}\`
- approval_tier: \`${approval_tier}\`
- human_gate_required: \`${human_gate_required}\`

## 5) 완료조건
- \`bash scripts/validate_all.sh\` 통과
- 관련 evidence 경로/해시 유효
- 최종 보고(1~4 포맷) 제출

## 6) 롤백조건
- validation fail
- 증빙 누락 또는 해시 불일치
- 승인 티어 상향 필요 발생
EOF

goal_hash="$(bash "$ROOT_DIR/scripts/hash_file.sh" "$ROOT_DIR/$tmp_goal_rel")"
intent_hash="$(bash "$ROOT_DIR/scripts/hash_file.sh" "$ROOT_DIR/$tmp_intent_rel")"
brief_hash="$(bash "$ROOT_DIR/scripts/hash_file.sh" "$ROOT_DIR/$brief_rel")"

cat > "$ROOT_DIR/$evidence_rel" <<EOF
{
  "version": "v0.1",
  "service_id": "${service_slug}",
  "owner": "${owner}",
  "risk_tier": "${risk_tier}",
  "approval_tier": "${approval_tier}",
  "human_gate_required": ${human_gate_required},
  "artifacts": [
    { "path": "${tmp_goal_rel}", "sha256": "${goal_hash}" },
    { "path": "${tmp_intent_rel}", "sha256": "${intent_hash}" },
    { "path": "${brief_rel}", "sha256": "${brief_hash}" }
  ]
}
EOF

echo "MACRO_PLAN_PACK_OK"
echo "goal=${tmp_goal_rel}"
echo "intent=${tmp_intent_rel}"
echo "brief=${brief_rel}"
echo "evidence=${evidence_rel}"
