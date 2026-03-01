#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 || $# -gt 4 ]]; then
  echo "Usage: $0 <service_id> <plan_json> <out_dir> [proposal_packets_dir]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
service_id="$1"
plan_rel="$2"
out_dir="$3"
proposal_dir_rel="${4:-services/$service_id/agent-roles/proposal-packets}"

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing command: $1" >&2; exit 1; }
}

sha_text() {
  local input="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    printf '%s' "$input" | sha256sum | awk '{print $1}'
  else
    printf '%s' "$input" | shasum -a 256 | awk '{print $1}'
  fi
}

require jq

plan_path="$ROOT_DIR/$plan_rel"
proposal_dir_path="$ROOT_DIR/$proposal_dir_rel"

if [[ ! -f "$plan_path" ]]; then
  echo "PLAN_FILE_MISSING $plan_rel" >&2
  exit 1
fi

if [[ ! -d "$proposal_dir_path" ]]; then
  echo "PROPOSAL_DIR_MISSING $proposal_dir_rel" >&2
  exit 1
fi

plan_service_id="$(jq -r '.service_id // ""' "$plan_path")"
if [[ "$plan_service_id" != "$service_id" ]]; then
  echo "PLAN_SERVICE_ID_MISMATCH expected=$service_id actual=$plan_service_id" >&2
  exit 1
fi

mkdir -p "$out_dir"
trace_file="$out_dir/trace.jsonl"
: > "$trace_file"

cp "$plan_path" "$out_dir/plan.json"
plan_hash="$(bash "$ROOT_DIR/scripts/hash_ref.sh" "$out_dir/plan.json")"

phase_manifest="[]"
prev_hash="GENESIS"
record_hash_file="$out_dir/.record_hash"

args_hash_plan="$(sha_text "{\"service_id\":\"$service_id\",\"intent\":\"uiux-plan\"}")"
bash "$ROOT_DIR/scripts/trace_append.sh" \
  "$trace_file" \
  "$prev_hash" \
  "PLAN_UIUX" \
  "$args_hash_plan" \
  "$plan_hash" \
  "[\"$plan_hash\"]" \
  "180" \
  "approved" \
  "$record_hash_file"
prev_hash="$(cat "$record_hash_file")"

while IFS=$'\t' read -r phase_id owner_role; do
  [[ -n "$phase_id" ]] || continue
  proposal_rel="$proposal_dir_rel/${phase_id}.proposal.v0.1.json"
  proposal_path="$ROOT_DIR/$proposal_rel"

  if [[ ! -f "$proposal_path" ]]; then
    echo "PROPOSAL_FILE_MISSING $proposal_rel" >&2
    rm -f "$record_hash_file"
    exit 1
  fi

  cp "$proposal_path" "$out_dir/${phase_id}.proposal.json"
  proposal_hash="$(bash "$ROOT_DIR/scripts/hash_ref.sh" "$out_dir/${phase_id}.proposal.json")"
  proposal_output_kind="$(jq -r '.output_kind' "$proposal_path")"
  proposal_state_refs="$(jq -c '.state_refs' "$proposal_path")"

  args_hash_phase="$(sha_text "$(jq -cn --arg phase_id "$phase_id" --arg owner_role "$owner_role" '{phase_id:$phase_id,owner_role:$owner_role}' | jq -cS .)")"
  evidence_refs_json="$(jq -cn --arg plan_hash "$plan_hash" --arg proposal_hash "$proposal_hash" '[$plan_hash, $proposal_hash]')"

  bash "$ROOT_DIR/scripts/trace_append.sh" \
    "$trace_file" \
    "$prev_hash" \
    "PHASE_PACKET" \
    "$args_hash_phase" \
    "$proposal_hash" \
    "$evidence_refs_json" \
    "220" \
    "approved" \
    "$record_hash_file"
  prev_hash="$(cat "$record_hash_file")"

  phase_manifest="$(printf '%s' "$phase_manifest" | jq -c \
    --arg phase_id "$phase_id" \
    --arg owner_role "$owner_role" \
    --arg proposal_ref "$proposal_hash" \
    --arg output_kind "$proposal_output_kind" \
    --argjson state_refs "$proposal_state_refs" \
    '. + [{
      phase_id:$phase_id,
      owner_role_id:$owner_role,
      proposal_ref:$proposal_ref,
      output_kind:$output_kind,
      state_refs:$state_refs
    }]')"
done < <(jq -r '.phases[] | [.phase_id, .owner_role_id] | @tsv' "$plan_path")

printf '%s\n' "$phase_manifest" > "$out_dir/phase_manifest.json"
phase_manifest_hash="$(bash "$ROOT_DIR/scripts/hash_ref.sh" "$out_dir/phase_manifest.json")"
args_hash_manifest="$(sha_text "{\"service_id\":\"$service_id\",\"intent\":\"phase-manifest\"}")"
bash "$ROOT_DIR/scripts/trace_append.sh" \
  "$trace_file" \
  "$prev_hash" \
  "FREEZE_STATE" \
  "$args_hash_manifest" \
  "$phase_manifest_hash" \
  "[\"$plan_hash\"]" \
  "140" \
  "approved" \
  "$record_hash_file"

last_record_hash="$(cat "$record_hash_file")"
rm -f "$record_hash_file"

jq -cn \
  --arg service_id "$service_id" \
  --arg plan_ref "$plan_hash" \
  --arg phase_manifest_ref "$phase_manifest_hash" \
  --arg trace_head "$last_record_hash" \
  '{service_id:$service_id, verdict:"approved", plan_ref:$plan_ref, phase_manifest_ref:$phase_manifest_ref, trace_head:$trace_head}' \
  > "$out_dir/final_result.json"

echo "UIUX_BRIDGE_PASS service_id=$service_id trace_head=$last_record_hash"
