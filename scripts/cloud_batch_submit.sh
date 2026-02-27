#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

service_id=""
jobs_manifest=""
provider="manifest"
run_id=""

usage() {
  echo "Usage: $0 --service <slug> --jobs-manifest <path> --run-id <id> [--provider <name>]" >&2
}

while (( $# > 0 )); do
  case "$1" in
    --service)
      service_id="${2:-}"
      shift 2
      ;;
    --jobs-manifest)
      jobs_manifest="${2:-}"
      shift 2
      ;;
    --provider)
      provider="${2:-}"
      shift 2
      ;;
    --run-id)
      run_id="${2:-}"
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

if [[ -z "$service_id" || -z "$jobs_manifest" || -z "$run_id" ]]; then
  usage
  exit 1
fi
if [[ ! "$service_id" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "INVALID_SERVICE_ID $service_id" >&2
  exit 1
fi
if [[ ! "$run_id" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]*$ ]]; then
  echo "INVALID_RUN_ID $run_id" >&2
  exit 1
fi
if [[ ! -f "$jobs_manifest" ]]; then
  echo "JOBS_MANIFEST_MISSING $jobs_manifest" >&2
  exit 1
fi

if ! jq -e '
  .version=="v0.1" and
  (.service_id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
  (.run_id|type=="string" and test("^[a-zA-Z0-9][a-zA-Z0-9._-]*$")) and
  (.jobs|type=="array" and length>0) and
  (all(.jobs[];
    (.job_id|type=="string" and test("^[a-zA-Z0-9][a-zA-Z0-9._-]*$")) and
    (.objective_ref|type=="string" and length>0) and
    (.input_artifacts|type=="array") and
    (all(.input_artifacts[]?;
      (.path|type=="string" and length>0) and
      (.sha256|type=="string" and test("^[a-f0-9]{64}$")) and
      (.role|type=="string" and length>0)
    )) and
    (.expected_outputs|type=="array" and length>0) and
    (all(.expected_outputs[];
      (.role|type=="string" and length>0) and
      ((.required // true)|type=="boolean")
    ))
  ))
' "$jobs_manifest" >/dev/null 2>&1; then
  echo "JOBS_MANIFEST_SCHEMA_FAIL $jobs_manifest" >&2
  exit 1
fi

manifest_service="$(jq -r '.service_id' "$jobs_manifest")"
manifest_run_id="$(jq -r '.run_id' "$jobs_manifest")"
if [[ "$manifest_service" != "$service_id" ]]; then
  echo "SERVICE_ID_MISMATCH arg=$service_id manifest=$manifest_service" >&2
  exit 1
fi
if [[ "$manifest_run_id" != "$run_id" ]]; then
  echo "RUN_ID_MISMATCH arg=$run_id manifest=$manifest_run_id" >&2
  exit 1
fi

batch_dir="$ROOT_DIR/traces/governance/batch/$run_id"
mkdir -p "$batch_dir"
cp "$jobs_manifest" "$batch_dir/jobs.manifest.v0.1.json"

jobs_sha="$(bash "$ROOT_DIR/scripts/hash_file.sh" "$batch_dir/jobs.manifest.v0.1.json")"
job_count="$(jq '.jobs | length' "$batch_dir/jobs.manifest.v0.1.json")"

jq -cn \
  --arg version "v0.1" \
  --arg service_id "$service_id" \
  --arg run_id "$run_id" \
  --arg provider "$provider" \
  --arg jobs_manifest_path "traces/governance/batch/$run_id/jobs.manifest.v0.1.json" \
  --arg jobs_manifest_sha256 "$jobs_sha" \
  --argjson job_count "$job_count" \
  '{
    version: $version,
    service_id: $service_id,
    run_id: $run_id,
    provider: $provider,
    status: "submitted",
    jobs_manifest_path: $jobs_manifest_path,
    jobs_manifest_sha256: $jobs_manifest_sha256,
    job_count: $job_count
  }' > "$batch_dir/submit.receipt.json"

echo "CLOUD_BATCH_SUBMIT_OK run_id=$run_id provider=$provider job_count=$job_count"
