#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 || $# -gt 4 ]]; then
  echo "Usage: $0 <intent_id> <approve|reject> <actor> [bridge_dir]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
intent_id="$1"
decision="$2"
actor="$3"
bridge_dir="${4:-$ROOT_DIR/traces/bridge}"
queue_path="$bridge_dir/queue/${intent_id}.queue.json"

if [[ ! -f "$queue_path" ]]; then
  echo "QUEUE_ITEM_MISSING $intent_id" >&2
  exit 1
fi

if [[ "$decision" != "approve" && "$decision" != "reject" ]]; then
  echo "INVALID_DECISION $decision" >&2
  exit 1
fi

mkdir -p "$bridge_dir"/{approved,rejected,logs}
now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

current_status="$(jq -r '.status' "$queue_path")"
if [[ "$current_status" != "awaiting_human_gate" ]]; then
  echo "GATE_NOT_REQUIRED current_status=$current_status"
  exit 0
fi

next_status="ready"
out_dir="$bridge_dir/approved"
if [[ "$decision" == "reject" ]]; then
  next_status="rejected"
  out_dir="$bridge_dir/rejected"
fi

tmp="$(mktemp)"
jq --arg status "$next_status" --arg now "$now" --arg actor "$actor" '.status=$status | .gate_decision={at:$now,actor:$actor}' "$queue_path" > "$tmp"
mv "$tmp" "$queue_path"
cp "$queue_path" "$out_dir/${intent_id}.json"

jq -cn \
  --arg ts "$now" \
  --arg event "human_gate_${decision}d" \
  --arg intent_id "$intent_id" \
  --arg actor "$actor" \
  --arg status "$next_status" \
  '{ts:$ts,event:$event,intent_id:$intent_id,actor:$actor,status:$status}' \
  >> "$bridge_dir/logs/events.jsonl"

echo "HUMAN_GATE_OK intent_id=$intent_id status=$next_status"
