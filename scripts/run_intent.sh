#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <envelope_json> <out_dir>" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
envelope="$1"
out_dir="$2"

mkdir -p "$out_dir"
trace_file="$out_dir/trace.jsonl"
: > "$trace_file"

state_ref_expected="$(bash "$ROOT_DIR/scripts/hash_ref.sh" "$ROOT_DIR/fixtures/state.json")"
acceptance_ref_expected="$(bash "$ROOT_DIR/scripts/hash_ref.sh" "$ROOT_DIR/fixtures/acceptance.tests.json")"
state_ref_actual="$(jq -r '.state_ref' "$envelope")"
acceptance_ref_actual="$(jq -r '.acceptance_tests_ref' "$envelope")"

if [[ "$state_ref_expected" != "$state_ref_actual" ]]; then
  echo "STATE_REF_MISMATCH" >&2
  exit 1
fi
if [[ "$acceptance_ref_expected" != "$acceptance_ref_actual" ]]; then
  echo "ACCEPTANCE_REF_MISMATCH" >&2
  exit 1
fi

plan='{"steps":["PLAN","COLLECT_EVIDENCE","EVAL","FREEZE_STATE"]}'
printf '%s\n' "$plan" > "$out_dir/plan.json"
plan_hash="$(bash "$ROOT_DIR/scripts/hash_ref.sh" "$out_dir/plan.json")"

prev_hash="GENESIS"
record_hash_file="$out_dir/.record_hash"

args_hash_plan="$(printf '%s' '{"intent":"plan"}' | jq -cS . | { if command -v sha256sum >/dev/null 2>&1; then sha256sum; else shasum -a 256; fi; } | awk '{print $1}')"
output_hash_plan="$plan_hash"
bash "$ROOT_DIR/scripts/trace_append.sh" "$trace_file" "$prev_hash" "PLAN" "$args_hash_plan" "$output_hash_plan" "[]" "200" "approved" "$record_hash_file"
prev_hash="$(cat "$record_hash_file")"

evidence_hash="$(bash "$ROOT_DIR/scripts/hash_ref.sh" "$ROOT_DIR/fixtures/evidence.summary.json")"
args_hash_collect="$(printf '%s' '{"intent":"collect"}' | jq -cS . | { if command -v sha256sum >/dev/null 2>&1; then sha256sum; else shasum -a 256; fi; } | awk '{print $1}')"
bash "$ROOT_DIR/scripts/trace_append.sh" "$trace_file" "$prev_hash" "COLLECT_EVIDENCE" "$args_hash_collect" "$evidence_hash" "[\"$evidence_hash\"]" "300" "approved" "$record_hash_file"
prev_hash="$(cat "$record_hash_file")"

verdict="approved"
required_sections="$(jq -r '.required_sections[]' "$ROOT_DIR/fixtures/acceptance.tests.json")"
for sec in $required_sections; do
  if ! jq -e --arg s "$sec" '.sections | index($s) != null' "$ROOT_DIR/fixtures/evidence.summary.json" >/dev/null; then
    verdict="rejected"
  fi
done

hall_score="$(jq -r '.hallucination_score' "$ROOT_DIR/fixtures/evidence.summary.json")"
max_hall="$(jq -r '.max_hallucination_score' "$ROOT_DIR/fixtures/acceptance.tests.json")"
if awk "BEGIN{exit !($hall_score <= $max_hall)}"; then :; else verdict="rejected"; fi

must_sources="$(jq -r '.must_include_sources' "$ROOT_DIR/fixtures/acceptance.tests.json")"
source_value="$(jq -r '.source' "$ROOT_DIR/fixtures/evidence.summary.json")"
if [[ "$must_sources" == "true" && -z "$source_value" ]]; then
  verdict="rejected"
fi

eval_output="$(jq -cn --arg verdict "$verdict" --arg evidence_ref "$evidence_hash" '{verdict:$verdict, evidence_ref:$evidence_ref}')"
printf '%s\n' "$eval_output" > "$out_dir/eval.json"
eval_hash="$(bash "$ROOT_DIR/scripts/hash_ref.sh" "$out_dir/eval.json")"
args_hash_eval="$(printf '%s' '{"intent":"eval"}' | jq -cS . | { if command -v sha256sum >/dev/null 2>&1; then sha256sum; else shasum -a 256; fi; } | awk '{print $1}')"
bash "$ROOT_DIR/scripts/trace_append.sh" "$trace_file" "$prev_hash" "EVAL" "$args_hash_eval" "$eval_hash" "[\"$evidence_hash\"]" "240" "$verdict" "$record_hash_file"
prev_hash="$(cat "$record_hash_file")"

final_state="$(jq -cn --arg prior_state_ref "$state_ref_actual" --arg verdict "$verdict" --arg plan_ref "$plan_hash" '{prior_state_ref:$prior_state_ref, verdict:$verdict, plan_ref:$plan_ref}')"
printf '%s\n' "$final_state" > "$out_dir/final_state.json"
final_state_hash="$(bash "$ROOT_DIR/scripts/hash_ref.sh" "$out_dir/final_state.json")"
args_hash_freeze="$(printf '%s' '{"intent":"freeze"}' | jq -cS . | { if command -v sha256sum >/dev/null 2>&1; then sha256sum; else shasum -a 256; fi; } | awk '{print $1}')"
bash "$ROOT_DIR/scripts/trace_append.sh" "$trace_file" "$prev_hash" "FREEZE_STATE" "$args_hash_freeze" "$final_state_hash" "[\"$evidence_hash\"]" "120" "$verdict" "$record_hash_file"

last_record_hash="$(cat "$record_hash_file")"
rm -f "$record_hash_file"

jq -cn \
  --arg intent_id "$(jq -r '.intent_id' "$envelope")" \
  --arg verdict "$verdict" \
  --arg trace_head "$last_record_hash" \
  --arg plan_ref "$plan_hash" \
  --arg final_state_ref "$final_state_hash" \
  '{intent_id:$intent_id, verdict:$verdict, trace_head:$trace_head, plan_ref:$plan_ref, final_state_ref:$final_state_ref}' \
  > "$out_dir/final_result.json"

echo "RUN_PASS verdict=$verdict trace_head=$last_record_hash"
