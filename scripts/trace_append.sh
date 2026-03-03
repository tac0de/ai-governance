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
genesis_prev_hash="0000000000000000000000000000000000000000000000000000000000000000"

require() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "MISSING_COMMAND $1" >&2
    exit 1
  }
}

ensure_hash64() {
  local label="$1"
  local value="$2"
  if [[ ! "$value" =~ ^[a-f0-9]{64}$ ]]; then
    echo "INVALID_HASH ${label}" >&2
    exit 1
  fi
}

require jq

ensure_hash64 "prev_hash" "$prev_hash"
ensure_hash64 "args_hash" "$args_hash"
ensure_hash64 "output_hash" "$output_hash"

if [[ -z "$opcode" ]]; then
  echo "INVALID_OPCODE" >&2
  exit 1
fi

if [[ ! "$tokens_used" =~ ^[0-9]+$ ]]; then
  echo "INVALID_TOKENS_USED" >&2
  exit 1
fi

case "$verdict" in
  approved|rejected|retry) ;;
  *)
    echo "INVALID_VERDICT" >&2
    exit 1
    ;;
esac

if ! jq -e 'type == "array" and all(.[]; type == "string" and test("^[a-f0-9]{64}$"))' <<<"$evidence_refs_json" >/dev/null 2>&1; then
  echo "INVALID_EVIDENCE_REFS" >&2
  exit 1
fi

if [[ "$measured_usage_json" != "null" ]]; then
  if ! jq -e '
    type == "object" and
    (.provider | type == "string" and length > 0) and
    (.model | type == "string" and length > 0) and
    (.tokens_prompt | type == "number" and . >= 0 and floor == .) and
    (.tokens_completion | type == "number" and . >= 0 and floor == .) and
    (.tokens_total | type == "number" and . >= 0 and floor == .) and
    (.source_ref | type == "string" and test("^[a-f0-9]{64}$")) and
    ((has("request_id") | not) or (.request_id | type == "string" and length > 0))
  ' <<<"$measured_usage_json" >/dev/null 2>&1; then
    echo "INVALID_MEASURED_USAGE" >&2
    exit 1
  fi
fi

if [[ -f "$trace_file" ]]; then
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if ! jq -e . >/dev/null 2>&1 <<<"$line"; then
      echo "INVALID_TRACE_FILE $trace_file" >&2
      exit 1
    fi
  done < "$trace_file"

  if [[ -s "$trace_file" ]]; then
    last_record_hash="$(tail -n 1 "$trace_file" | jq -r '.record_hash')"
    if [[ "$last_record_hash" != "$prev_hash" ]]; then
      echo "PREV_HASH_MISMATCH" >&2
      exit 1
    fi
  elif [[ "$prev_hash" != "$genesis_prev_hash" ]]; then
    echo "INVALID_GENESIS_PREV_HASH" >&2
    exit 1
  fi
elif [[ "$prev_hash" != "$genesis_prev_hash" ]]; then
  echo "INVALID_GENESIS_PREV_HASH" >&2
  exit 1
fi

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
