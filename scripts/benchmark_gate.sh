#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SPEC_PATH="${ROOT_DIR}/control/benchmarks/efficiency_benchmark_spec.v0.1.json"
BASELINE_PATH="${ROOT_DIR}/fixtures/benchmark/baseline.kpi.json"
CANDIDATE_PATH="${ROOT_DIR}/fixtures/benchmark/candidate.kpi.json"

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing command: $1" >&2; exit 1; }
}

require jq

jq -e '.version=="v0.1" and .kpi_thresholds!=null' "$SPEC_PATH" >/dev/null

# Basic schema-like checks (deterministic and local)
for file in "$BASELINE_PATH" "$CANDIDATE_PATH"; do
  jq -e '
    (.service_id|type=="string" and length>0) and
    (.window_days|type=="number" and .>0) and
    (.scale=="1k_dau" or .scale=="10k_dau" or .scale=="100k_dau") and
    (.group=="baseline" or .group=="candidate") and
    (.acceptance_pass_rate>=0 and .acceptance_pass_rate<=1) and
    (.cache_hit_rate>=0 and .cache_hit_rate<=1) and
    (.fallback_rate>=0 and .fallback_rate<=1) and
    (.cost_per_successful_session_usd>=0) and
    (.p95_latency_ms>=0)
  ' "$file" >/dev/null
done

min_pass_rate="$(jq -r '.kpi_thresholds.min_acceptance_pass_rate' "$SPEC_PATH")"
min_cache_hit="$(jq -r '.kpi_thresholds.min_cache_hit_rate' "$SPEC_PATH")"
max_fallback="$(jq -r '.kpi_thresholds.max_fallback_rate' "$SPEC_PATH")"
min_cost_reduction="$(jq -r '.kpi_thresholds.min_cost_reduction_vs_baseline' "$SPEC_PATH")"

candidate_pass_rate="$(jq -r '.acceptance_pass_rate' "$CANDIDATE_PATH")"
candidate_cache_hit="$(jq -r '.cache_hit_rate' "$CANDIDATE_PATH")"
candidate_fallback="$(jq -r '.fallback_rate' "$CANDIDATE_PATH")"

baseline_cost="$(jq -r '.cost_per_successful_session_usd' "$BASELINE_PATH")"
candidate_cost="$(jq -r '.cost_per_successful_session_usd' "$CANDIDATE_PATH")"

cost_reduction="$(awk -v b="$baseline_cost" -v c="$candidate_cost" 'BEGIN { if (b==0) print 0; else printf "%.6f", (b-c)/b }')"

pass=1

awk -v v="$candidate_pass_rate" -v t="$min_pass_rate" 'BEGIN{exit !(v>=t)}' || pass=0
awk -v v="$candidate_cache_hit" -v t="$min_cache_hit" 'BEGIN{exit !(v>=t)}' || pass=0
awk -v v="$candidate_fallback" -v t="$max_fallback" 'BEGIN{exit !(v<=t)}' || pass=0
awk -v v="$cost_reduction" -v t="$min_cost_reduction" 'BEGIN{exit !(v>=t)}' || pass=0

if [[ "$pass" -ne 1 ]]; then
  echo "BENCHMARK_FAIL"
  echo "candidate_pass_rate=$candidate_pass_rate (threshold=$min_pass_rate)"
  echo "candidate_cache_hit=$candidate_cache_hit (threshold=$min_cache_hit)"
  echo "candidate_fallback=$candidate_fallback (threshold_max=$max_fallback)"
  echo "cost_reduction=$cost_reduction (threshold=$min_cost_reduction)"
  exit 1
fi

echo "BENCHMARK_PASS"
echo "candidate_pass_rate=$candidate_pass_rate"
echo "candidate_cache_hit=$candidate_cache_hit"
echo "candidate_fallback=$candidate_fallback"
echo "cost_reduction=$cost_reduction"
