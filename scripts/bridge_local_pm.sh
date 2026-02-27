#!/usr/bin/env bash
set -euo pipefail

# bridge_local_pm.sh
# Create BridgeIntent JSON locally (no external API), then optionally auto-submit/dispatch.
#
# Usage:
#   bash scripts/bridge_local_pm.sh <intent_id> <objective_text_file> [intent_out_json] [approval_tier] [human_gate_required] [--auto]

if [[ $# -lt 2 || $# -gt 6 ]]; then
  echo "Usage: $0 <intent_id> <objective_text_file> [intent_out_json] [approval_tier] [human_gate_required] [--auto]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
intent_id="$1"
objective_file="$2"
intent_out="${3:-$ROOT_DIR/traces/local/pm_intent.local.json}"
approval_tier="${4:-medium}"
human_gate_required="${5:-false}"
auto_mode="false"

if [[ "${6:-}" == "--auto" || "${5:-}" == "--auto" || "${4:-}" == "--auto" || "${3:-}" == "--auto" ]]; then
  auto_mode="true"
fi

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing command: $1" >&2; exit 1; }
}

require jq

if [[ ! -f "$objective_file" ]]; then
  echo "OBJECTIVE_FILE_MISSING $objective_file" >&2
  exit 1
fi

if ! [[ "$intent_id" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]*$ ]]; then
  echo "INVALID_INTENT_ID" >&2
  exit 1
fi

if [[ "$approval_tier" != "low" && "$approval_tier" != "medium" && "$approval_tier" != "high" ]]; then
  echo "INVALID_APPROVAL_TIER" >&2
  exit 1
fi

if [[ "$human_gate_required" != "true" && "$human_gate_required" != "false" ]]; then
  echo "INVALID_HUMAN_GATE_FLAG" >&2
  exit 1
fi

mkdir -p "$(dirname "$intent_out")"
objective="$(cat "$objective_file")"
target_executor="${TARGET_EXECUTOR:-service-review}"

# Deterministic default constraints for local PM mode.
constraints_json='[
  "Keep scope minimal and implementation-focused.",
  "Preserve deterministic behavior for verdict-critical paths.",
  "Preserve traceability with hash-referenced evidence and prompt/version refs.",
  "Fallback path must remain available for external-model failures.",
  "CI must gate merge on validation and deterministic tests."
]'

intent_json="$(jq -cn \
  --arg intent_id "$intent_id" \
  --arg objective "$objective" \
  --arg approval_tier "$approval_tier" \
  --argjson human_gate_required "$human_gate_required" \
  --arg target_executor "$target_executor" \
  --argjson constraints "$constraints_json" \
  '{
    intent_id:$intent_id,
    objective:$objective,
    constraints:$constraints,
    approval_tier:$approval_tier,
    human_gate_required:$human_gate_required,
    target_executor:$target_executor,
    evidence_refs:[]
  }')"

if ! printf '%s' "$intent_json" | jq -e '
  (.intent_id|type=="string" and test("^[a-zA-Z0-9][a-zA-Z0-9._-]*$")) and
  (.objective|type=="string" and length>0) and
  (.constraints|type=="array" and length>0 and all(.[]; type=="string" and length>0)) and
  (.approval_tier=="low" or .approval_tier=="medium" or .approval_tier=="high") and
  (.human_gate_required|type=="boolean") and
  (.target_executor|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
  (.evidence_refs|type=="array")
' >/dev/null; then
  echo "LOCAL_PM_SCHEMA_FAIL" >&2
  exit 1
fi

printf '%s\n' "$intent_json" > "$intent_out"
echo "LOCAL_PM_OK out=$intent_out"

if [[ "$auto_mode" == "true" ]]; then
  submit_out="$(bash "$ROOT_DIR/scripts/bridge_submit.sh" "$intent_out")"
  echo "$submit_out"

  q_intent_id="$(jq -r '.intent_id' "$intent_out")"
  queue_file="$ROOT_DIR/traces/bridge/queue/${q_intent_id}.queue.json"
  if [[ -f "$queue_file" ]]; then
    status="$(jq -r '.status' "$queue_file")"
    if [[ "$status" == "ready" ]]; then
      bash "$ROOT_DIR/scripts/bridge_dispatch.sh"
    else
      echo "AUTO_HOLD status=$status intent_id=$q_intent_id"
    fi
  fi
fi
