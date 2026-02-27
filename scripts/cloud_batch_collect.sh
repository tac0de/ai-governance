#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

run_id=""
provider="manifest"
results_manifest=""

usage() {
  echo "Usage: $0 --run-id <id> [--provider <name>] [--results-manifest <path>]" >&2
}

while (( $# > 0 )); do
  case "$1" in
    --run-id)
      run_id="${2:-}"
      shift 2
      ;;
    --provider)
      provider="${2:-}"
      shift 2
      ;;
    --results-manifest)
      results_manifest="${2:-}"
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
if [[ ! "$run_id" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]*$ ]]; then
  echo "INVALID_RUN_ID $run_id" >&2
  exit 1
fi

batch_dir="$ROOT_DIR/traces/governance/batch/$run_id"
mkdir -p "$batch_dir"
jobs_manifest_path="$batch_dir/jobs.manifest.v0.1.json"
if [[ ! -f "$jobs_manifest_path" ]]; then
  echo "JOBS_MANIFEST_MISSING $jobs_manifest_path" >&2
  exit 1
fi

if [[ -z "$results_manifest" ]]; then
  if [[ -f "$batch_dir/results.manifest.v0.1.json" ]]; then
    results_manifest="$batch_dir/results.manifest.v0.1.json"
  else
    echo "RESULTS_MANIFEST_MISSING use --results-manifest <path>" >&2
    exit 1
  fi
fi

if [[ ! -f "$results_manifest" ]]; then
  echo "RESULTS_MANIFEST_MISSING $results_manifest" >&2
  exit 1
fi

if ! jq -e '
  .version=="v0.1" and
  (.service_id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
  (.run_id|type=="string" and test("^[a-zA-Z0-9][a-zA-Z0-9._-]*$")) and
  (.results|type=="array" and length>0) and
  (all(.results[];
    (.job_id|type=="string" and test("^[a-zA-Z0-9][a-zA-Z0-9._-]*$")) and
    (.status=="success" or .status=="failed" or .status=="timeout" or .status=="canceled") and
    (.artifacts|type=="array") and
    (all(.artifacts[]?;
      (.path|type=="string" and length>0) and
      (.sha256|type=="string" and test("^[a-f0-9]{64}$")) and
      (.role|type=="string" and length>0)
    )) and
    (.usage|type=="object") and
    (.usage.tokens_in|type=="number" and .>=0) and
    (.usage.tokens_out|type=="number" and .>=0) and
    (.usage.latency_ms|type=="number" and .>=0)
  ))
' "$results_manifest" >/dev/null 2>&1; then
  echo "RESULTS_MANIFEST_SCHEMA_FAIL $results_manifest" >&2
  exit 1
fi

jobs_service="$(jq -r '.service_id' "$jobs_manifest_path")"
jobs_run="$(jq -r '.run_id' "$jobs_manifest_path")"
results_service="$(jq -r '.service_id' "$results_manifest")"
results_run="$(jq -r '.run_id' "$results_manifest")"

if [[ "$jobs_service" != "$results_service" ]]; then
  echo "SERVICE_ID_MISMATCH jobs=$jobs_service results=$results_service" >&2
  exit 1
fi
if [[ "$jobs_run" != "$results_run" || "$jobs_run" != "$run_id" ]]; then
  echo "RUN_ID_MISMATCH jobs=$jobs_run results=$results_run arg=$run_id" >&2
  exit 1
fi

if [[ "$results_manifest" != "$batch_dir/results.manifest.v0.1.json" ]]; then
  cp "$results_manifest" "$batch_dir/results.manifest.v0.1.json"
fi

results_sha="$(bash "$ROOT_DIR/scripts/hash_file.sh" "$batch_dir/results.manifest.v0.1.json")"
total_jobs="$(jq '.results | length' "$batch_dir/results.manifest.v0.1.json")"
success_jobs="$(jq '[.results[] | select(.status=="success")] | length' "$batch_dir/results.manifest.v0.1.json")"
failed_jobs="$(jq '[.results[] | select(.status!="success")] | length' "$batch_dir/results.manifest.v0.1.json")"
tokens_in_total="$(jq '[.results[].usage.tokens_in] | add // 0' "$batch_dir/results.manifest.v0.1.json")"
tokens_out_total="$(jq '[.results[].usage.tokens_out] | add // 0' "$batch_dir/results.manifest.v0.1.json")"
max_latency_ms="$(jq '[.results[].usage.latency_ms] | max // 0' "$batch_dir/results.manifest.v0.1.json")"

jq -cn \
  --arg version "v0.1" \
  --arg service_id "$results_service" \
  --arg run_id "$run_id" \
  --arg provider "$provider" \
  --arg results_manifest_path "traces/governance/batch/$run_id/results.manifest.v0.1.json" \
  --arg results_manifest_sha256 "$results_sha" \
  --argjson total_jobs "$total_jobs" \
  --argjson success_jobs "$success_jobs" \
  --argjson failed_jobs "$failed_jobs" \
  --argjson tokens_in_total "$tokens_in_total" \
  --argjson tokens_out_total "$tokens_out_total" \
  --argjson max_latency_ms "$max_latency_ms" \
  '{
    version: $version,
    service_id: $service_id,
    run_id: $run_id,
    provider: $provider,
    results_manifest_path: $results_manifest_path,
    results_manifest_sha256: $results_manifest_sha256,
    summary: {
      total_jobs: $total_jobs,
      success_jobs: $success_jobs,
      failed_jobs: $failed_jobs,
      tokens_in_total: $tokens_in_total,
      tokens_out_total: $tokens_out_total,
      max_latency_ms: $max_latency_ms
    }
  }' > "$batch_dir/collect.snapshot.json"

echo "CLOUD_BATCH_COLLECT_OK run_id=$run_id total_jobs=$total_jobs"
