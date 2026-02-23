#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 9 || $# -gt 10 ]]; then
  echo "Usage: $0 <trace_file> <prev_hash> <opcode> <args_hash> <output_hash> <evidence_refs_json> <tokens_used> <verdict> <record_hash_out> [measured_usage_json]" >&2
  exit 1
fi

trace_file="$1"
prev_hash="$2"
opcode="$3"
args_hash="$4"
output_hash="$5"
evidence_refs_json="$6"
tokens_used="$7"
verdict="$8"
record_hash_out="$9"
measured_usage_json="${10:-null}"

record_nohash="$(jq -cn \
  --arg prev_hash "$prev_hash" \
  --arg opcode "$opcode" \
  --arg args_hash "$args_hash" \
  --arg output_hash "$output_hash" \
  --argjson evidence_refs "$evidence_refs_json" \
  --argjson tokens_used "$tokens_used" \
  --argjson measured_usage "$measured_usage_json" \
  --arg verdict "$verdict" \
  '{prev_hash:$prev_hash, opcode:$opcode, args_hash:$args_hash, output_hash:$output_hash, evidence_refs:$evidence_refs, cost:{tokens_used:$tokens_used}, verdict:$verdict}
   + (if $measured_usage == null then {} else {measured_usage:$measured_usage} end)'
)"

if command -v sha256sum >/dev/null 2>&1; then
  record_hash="$(printf '%s' "$record_nohash" | jq -cS . | sha256sum | awk '{print $1}')"
else
  record_hash="$(printf '%s' "$record_nohash" | jq -cS . | shasum -a 256 | awk '{print $1}')"
fi

record="$(printf '%s' "$record_nohash" | jq -c --arg h "$record_hash" '. + {record_hash:$h}')"
printf '%s\n' "$record" >> "$trace_file"
printf '%s' "$record_hash" > "$record_hash_out"
