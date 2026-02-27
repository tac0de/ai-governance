#!/usr/bin/env bash
set -euo pipefail

if [[ $# -gt 1 ]]; then
  echo "Usage: $0 [bridge_dir]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bridge_dir="${1:-$ROOT_DIR/traces/bridge}"
mkdir -p "$bridge_dir"/{queue,dispatched,logs}

now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
dispatched_ids=()

shopt -s nullglob
for file in "$bridge_dir"/queue/*.queue.json; do
  status="$(jq -r '.status' "$file")"
  if [[ "$status" != "ready" ]]; then
    continue
  fi

  intent_id="$(jq -r '.intent_id' "$file")"
  dispatch_packet="$(jq -cS '
    {
      intent_id:.intent_id,
      intent_ref:.intent_ref,
      target_executor:.intent.target_executor,
      objective:.intent.objective,
      constraints:.intent.constraints,
      evidence_refs:.intent.evidence_refs,
      submitted_at:.submitted_at
    }
    + (if (.intent|has("prompt_pack_id")) then {prompt_pack_id:.intent.prompt_pack_id} else {} end)
  ' "$file")"
  printf '%s\n' "$dispatch_packet" > "$bridge_dir/dispatched/${intent_id}.dispatch.json"

  tmp="$(mktemp)"
  jq --arg now "$now" '.status="dispatched" | .dispatched_at=$now' "$file" > "$tmp"
  mv "$tmp" "$file"

  jq -cn --arg ts "$now" --arg event "intent_dispatched" --arg intent_id "$intent_id" '{ts:$ts,event:$event,intent_id:$intent_id}' >> "$bridge_dir/logs/events.jsonl"
  dispatched_ids+=("$intent_id")
done

jq -cn --arg ts "$now" --argjson ids "$(printf '%s\n' "${dispatched_ids[@]:-}" | jq -R . | jq -s 'map(select(length>0))')" '{generated_at:$ts,dispatched_intents:$ids}' > "$bridge_dir/dispatched/manifest.json"

echo "DISPATCH_OK count=${#dispatched_ids[@]}"
