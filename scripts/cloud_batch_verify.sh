#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

run_id=""
strictness=""
service_arg=""
policy_file=""

usage() {
  echo "Usage: $0 --run-id <id> [--service <slug>] [--policy-file <path>] [--strictness hybrid|strict|soft]" >&2
}

fail_reasons=()
warnings=()
artifact_checks=0

add_fail() {
  fail_reasons+=("$1")
}

add_warn() {
  warnings+=("$1")
}

array_to_json() {
  local item
  if (( $# == 0 )); then
    printf '[]'
    return
  fi
  printf '%s\n' "$@" | jq -R . | jq -s .
}

while (( $# > 0 )); do
  case "$1" in
    --run-id)
      run_id="${2:-}"
      shift 2
      ;;
    --service)
      service_arg="${2:-}"
      shift 2
      ;;
    --policy-file)
      policy_file="${2:-}"
      shift 2
      ;;
    --strictness)
      strictness="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$run_id" ]]; then
  usage
  exit 1
fi
if [[ -n "$service_arg" && ! "$service_arg" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "INVALID_SERVICE $service_arg" >&2
  exit 1
fi

batch_dir="$ROOT_DIR/traces/governance/batch/$run_id"
jobs_manifest_path="$batch_dir/jobs.manifest.v0.1.json"
results_manifest_path="$batch_dir/results.manifest.v0.1.json"
verdict_path="$batch_dir/verify.verdict.json"
default_policy_path="$ROOT_DIR/policies/cloud_batch_policy.v0.1.json"

if [[ -z "$policy_file" ]]; then
  if [[ -n "$service_arg" && -f "$ROOT_DIR/services/$service_arg/cloud_batch.policy.v0.1.json" ]]; then
    policy_file="$ROOT_DIR/services/$service_arg/cloud_batch.policy.v0.1.json"
  else
    policy_file="$default_policy_path"
  fi
fi

if [[ ! -f "$policy_file" ]]; then
  add_fail "policy file missing: $policy_file"
fi

if (( ${#fail_reasons[@]} == 0 )); then
  if ! jq -e '
    .version=="v0.1" and
    (.thresholds.token_total|type=="number" and .>0) and
    (.thresholds.max_latency_ms|type=="number" and .>0) and
    (.thresholds.fail_rate|type=="number" and .>=0 and .<=1) and
    (.mode_defaults.strictness=="hybrid" or .mode_defaults.strictness=="strict" or .mode_defaults.strictness=="soft")
  ' "$policy_file" >/dev/null 2>&1; then
    add_fail "policy schema invalid: $policy_file"
  fi
fi

if (( ${#fail_reasons[@]} == 0 )); then
  TOKEN_TOTAL_THRESHOLD="$(jq -r '.thresholds.token_total' "$policy_file")"
  MAX_LATENCY_THRESHOLD_MS="$(jq -r '.thresholds.max_latency_ms' "$policy_file")"
  FAIL_RATE_THRESHOLD="$(jq -r '.thresholds.fail_rate' "$policy_file")"
  if [[ -z "$strictness" ]]; then
    strictness="$(jq -r '.mode_defaults.strictness' "$policy_file")"
  fi
fi

if [[ -z "$strictness" ]]; then
  strictness="hybrid"
fi
if [[ "$strictness" != "hybrid" && "$strictness" != "strict" && "$strictness" != "soft" ]]; then
  echo "INVALID_STRICTNESS $strictness" >&2
  exit 1
fi

if [[ ! -f "$jobs_manifest_path" ]]; then
  add_fail "jobs manifest missing: traces/governance/batch/$run_id/jobs.manifest.v0.1.json"
fi
if [[ ! -f "$results_manifest_path" ]]; then
  add_fail "results manifest missing: traces/governance/batch/$run_id/results.manifest.v0.1.json"
fi

service_id=""
total_jobs=0
success_jobs=0
failed_jobs=0
tokens_in_total=0
tokens_out_total=0
max_latency_ms=0
fail_rate=0

if [[ -f "$jobs_manifest_path" ]]; then
  service_id="$(jq -r '.service_id // "unknown-service"' "$jobs_manifest_path" 2>/dev/null || printf 'unknown-service')"
fi

if (( ${#fail_reasons[@]} == 0 )); then
  jobs_service="$(jq -r '.service_id' "$jobs_manifest_path")"
  results_service="$(jq -r '.service_id' "$results_manifest_path")"
  jobs_run="$(jq -r '.run_id' "$jobs_manifest_path")"
  results_run="$(jq -r '.run_id' "$results_manifest_path")"

  service_id="$jobs_service"
  if [[ -n "$service_arg" && "$jobs_service" != "$service_arg" ]]; then
    add_fail "service mismatch between --service ($service_arg) and jobs manifest ($jobs_service)"
  fi

  if [[ "$jobs_service" != "$results_service" ]]; then
    add_fail "service_id mismatch between jobs and results manifests"
  fi
  if [[ "$jobs_run" != "$results_run" || "$jobs_run" != "$run_id" ]]; then
    add_fail "run_id mismatch between manifests or argument"
  fi

  while IFS= read -r job_id; do
    if ! jq -e --arg job_id "$job_id" '.results | any(.job_id==$job_id)' "$results_manifest_path" >/dev/null 2>&1; then
      add_fail "missing result for job_id=$job_id"
    fi
  done < <(jq -r '.jobs[].job_id' "$jobs_manifest_path")

  while IFS=$'\t' read -r job_id role required; do
    [[ -n "$job_id" && -n "$role" ]] || continue
    if [[ "$required" != "true" ]]; then
      continue
    fi
    if ! jq -e --arg job_id "$job_id" --arg role "$role" \
      '.results | any(.job_id==$job_id and .status=="success" and (.artifacts | any(.role==$role)))' \
      "$results_manifest_path" >/dev/null 2>&1; then
      add_fail "missing required output role '$role' for successful job '$job_id'"
    fi
  done < <(jq -r '.jobs[] | .job_id as $job_id | .expected_outputs[] | [$job_id, .role, ((.required // true)|tostring)] | @tsv' "$jobs_manifest_path")

  while IFS=$'\t' read -r job_id status artifact_path expected_hash role; do
    [[ -n "$artifact_path" && -n "$expected_hash" ]] || continue
    if [[ "$status" != "success" ]]; then
      continue
    fi
    if [[ "$artifact_path" == /* ]]; then
      add_fail "artifact path must be repository-relative: $artifact_path"
      continue
    fi
    if [[ ! -f "$ROOT_DIR/$artifact_path" ]]; then
      add_fail "artifact missing for job '$job_id' role '$role': $artifact_path"
      continue
    fi
    actual_hash="$(bash "$ROOT_DIR/scripts/hash_file.sh" "$ROOT_DIR/$artifact_path")"
    if [[ "$actual_hash" != "$expected_hash" ]]; then
      add_fail "artifact hash mismatch for job '$job_id' role '$role': $artifact_path"
    fi
    artifact_checks=$((artifact_checks + 1))
  done < <(jq -r '.results[] | .job_id as $job_id | .status as $status | .artifacts[]? | [$job_id, $status, .path, .sha256, .role] | @tsv' "$results_manifest_path")

  total_jobs="$(jq '.results | length' "$results_manifest_path")"
  success_jobs="$(jq '[.results[] | select(.status=="success")] | length' "$results_manifest_path")"
  failed_jobs="$(jq '[.results[] | select(.status!="success")] | length' "$results_manifest_path")"
  tokens_in_total="$(jq '[.results[].usage.tokens_in] | add // 0' "$results_manifest_path")"
  tokens_out_total="$(jq '[.results[].usage.tokens_out] | add // 0' "$results_manifest_path")"
  max_latency_ms="$(jq '[.results[].usage.latency_ms] | max // 0' "$results_manifest_path")"
  fail_rate="$(awk -v f="$failed_jobs" -v t="$total_jobs" 'BEGIN { if (t==0) print 0; else printf "%.6f", f/t }')"

  if awk -v val="$tokens_in_total" -v val2="$tokens_out_total" -v thr="$TOKEN_TOTAL_THRESHOLD" 'BEGIN { exit !((val+val2) > thr) }'; then
    add_warn "token total exceeded threshold (${tokens_in_total}+${tokens_out_total} > ${TOKEN_TOTAL_THRESHOLD})"
  fi
  if awk -v val="$max_latency_ms" -v thr="$MAX_LATENCY_THRESHOLD_MS" 'BEGIN { exit !(val > thr) }'; then
    add_warn "max latency exceeded threshold (${max_latency_ms} > ${MAX_LATENCY_THRESHOLD_MS})"
  fi
  if awk -v val="$fail_rate" -v thr="$FAIL_RATE_THRESHOLD" 'BEGIN { exit !(val > thr) }'; then
    add_warn "fail rate exceeded threshold (${val} > ${thr})"
  fi
fi

if [[ "$strictness" == "strict" && ${#warnings[@]} -gt 0 ]]; then
  for w in "${warnings[@]}"; do
    add_fail "strict mode escalation: $w"
  done
fi

verification_status="pass"
if (( ${#fail_reasons[@]} > 0 )); then
  verification_status="fail"
fi

if (( ${#fail_reasons[@]} > 0 )); then
  fail_reasons_json="$(array_to_json "${fail_reasons[@]}")"
else
  fail_reasons_json='[]'
fi

if (( ${#warnings[@]} > 0 )); then
  warnings_json="$(array_to_json "${warnings[@]}")"
else
  warnings_json='[]'
fi

jq -cn \
  --arg version "v0.1" \
  --arg service_id "$service_id" \
  --arg run_id "$run_id" \
  --arg strictness "$strictness" \
  --arg verification_status "$verification_status" \
  --argjson total_jobs "$total_jobs" \
  --argjson success_jobs "$success_jobs" \
  --argjson failed_jobs "$failed_jobs" \
  --argjson tokens_in_total "$tokens_in_total" \
  --argjson tokens_out_total "$tokens_out_total" \
  --argjson max_latency_ms "$max_latency_ms" \
  --argjson fail_rate "$fail_rate" \
  --argjson artifact_checks "$artifact_checks" \
  --argjson fail_reasons "$fail_reasons_json" \
  --argjson warnings "$warnings_json" \
  '{
    version: $version,
    service_id: $service_id,
    run_id: $run_id,
    strictness: $strictness,
    verification_status: $verification_status,
    metrics: {
      total_jobs: $total_jobs,
      success_jobs: $success_jobs,
      failed_jobs: $failed_jobs,
      tokens_in_total: $tokens_in_total,
      tokens_out_total: $tokens_out_total,
      max_latency_ms: $max_latency_ms,
      fail_rate: $fail_rate,
      artifact_checks: $artifact_checks
    },
    fail_reasons: $fail_reasons,
    warnings: $warnings
  }' > "$verdict_path"

if [[ "$verification_status" == "fail" ]]; then
  echo "CLOUD_BATCH_VERIFY_FAIL run_id=$run_id strictness=$strictness" >&2
  exit 1
fi

echo "CLOUD_BATCH_VERIFY_PASS run_id=$run_id strictness=$strictness"
