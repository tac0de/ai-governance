#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <pm_intent_json> [bridge_dir]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
intent_path="$1"
bridge_dir="${2:-$ROOT_DIR/traces/bridge}"

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing command: $1" >&2; exit 1; }
}

hash_stdin() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum | awk '{print $1}'
  else
    shasum -a 256 | awk '{print $1}'
  fi
}

require jq

if [[ ! -f "$intent_path" ]]; then
  echo "INTENT_FILE_MISSING $intent_path" >&2
  exit 1
fi

if ! jq -e '
  (.intent_id|type=="string" and test("^[a-zA-Z0-9][a-zA-Z0-9._-]*$")) and
  (.objective|type=="string" and length>0) and
  (.constraints|type=="array" and length>0 and all(.[]; type=="string" and length>0)) and
  (.approval_tier=="low" or .approval_tier=="medium" or .approval_tier=="high") and
  (.human_gate_required|type=="boolean") and
  (.target_executor|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
  (.evidence_refs|type=="array") and
  (all(.evidence_refs[]?; (.path|type=="string" and length>0) and (.sha256|type=="string" and test("^[a-f0-9]{64}$"))))
' "$intent_path" >/dev/null 2>&1; then
  echo "INTENT_SCHEMA_FAIL" >&2
  exit 1
fi

routing_policy="$ROOT_DIR/policies/agent_routing_policy.v0.1.json"

if [[ ! -f "$routing_policy" ]]; then
  echo "AGENT_ROUTING_POLICY_MISSING $routing_policy" >&2
  exit 1
fi
if ! jq -e . "$routing_policy" >/dev/null 2>&1; then
  echo "AGENT_ROUTING_POLICY_INVALID_JSON $routing_policy" >&2
  exit 1
fi

approval_tier="$(jq -r '.approval_tier' "$intent_path")"
target_executor="$(jq -r '.target_executor' "$intent_path")"

if ! jq -e --arg tier "$approval_tier" --arg ex "$target_executor" '
  .allowed_executors_by_tier[$tier] | any(.==$ex)
' "$routing_policy" >/dev/null 2>&1; then
  echo "TARGET_EXECUTOR_NOT_ALLOWED tier=$approval_tier executor=$target_executor" >&2
  exit 1
fi

mkdir -p "$bridge_dir"/{inbox,queue,approved,rejected,dispatched,logs}

intent_id="$(jq -r '.intent_id' "$intent_path")"
canonical="$(jq -cS . "$intent_path")"
intent_ref="$(printf '%s' "$canonical" | hash_stdin)"
submitted_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

human_gate_required="$(jq -r '.human_gate_required' "$intent_path")"

status="ready"
if [[ "$approval_tier" == "high" || "$human_gate_required" == "true" ]]; then
  status="awaiting_human_gate"
fi

packet="$(jq -cn \
  --arg intent_id "$intent_id" \
  --arg intent_ref "$intent_ref" \
  --arg submitted_at "$submitted_at" \
  --arg status "$status" \
  --argjson intent "$canonical" \
  '{intent_id:$intent_id,intent_ref:$intent_ref,submitted_at:$submitted_at,status:$status,intent:$intent}')"

printf '%s\n' "$canonical" > "$bridge_dir/inbox/${intent_id}.intent.json"
printf '%s\n' "$packet" > "$bridge_dir/queue/${intent_id}.queue.json"

jq -cn \
  --arg ts "$submitted_at" \
  --arg event "intent_submitted" \
  --arg intent_id "$intent_id" \
  --arg intent_ref "$intent_ref" \
  --arg status "$status" \
  '{ts:$ts,event:$event,intent_id:$intent_id,intent_ref:$intent_ref,status:$status}' \
  >> "$bridge_dir/logs/events.jsonl"

echo "SUBMIT_OK intent_id=$intent_id status=$status intent_ref=$intent_ref"
