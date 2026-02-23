#!/usr/bin/env bash
set -euo pipefail

# One-shot local bridge pipeline for minimal interaction/token usage.
#
# Usage:
#   bash scripts/bridge_one_shot_local.sh <intent_id> <objective_file> [approval_tier] [human_gate_required] [auto_gate_actor]
#
# Example:
#   bash scripts/bridge_one_shot_local.sh tdp.phase2.ops_hardening tmp/pm_objective.txt high true architect-owner

if [[ $# -lt 2 || $# -gt 5 ]]; then
  echo "Usage: $0 <intent_id> <objective_file> [approval_tier] [human_gate_required] [auto_gate_actor]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
intent_id="$1"
objective_file="$2"
approval_tier="${3:-medium}"
human_gate_required="${4:-false}"
auto_gate_actor="${5:-}"

intent_out="$ROOT_DIR/tmp/${intent_id}.intent.local.json"

bash "$ROOT_DIR/scripts/bridge_local_pm.sh" "$intent_id" "$objective_file" "$intent_out" "$approval_tier" "$human_gate_required" --auto

queue_file="$ROOT_DIR/traces/bridge/queue/${intent_id}.queue.json"
if [[ ! -f "$queue_file" ]]; then
  echo "QUEUE_FILE_MISSING $queue_file" >&2
  exit 1
fi

status="$(jq -r '.status' "$queue_file")"
if [[ "$status" == "awaiting_human_gate" && -n "$auto_gate_actor" ]]; then
  bash "$ROOT_DIR/scripts/bridge_human_gate.sh" "$intent_id" approve "$auto_gate_actor"
  bash "$ROOT_DIR/scripts/bridge_dispatch.sh"
  status="dispatched"
fi

if [[ "$status" == "dispatched" || "$status" == "ready" ]]; then
  bash "$ROOT_DIR/scripts/bridge_consume.sh"
fi

echo "ONE_SHOT_OK intent_id=$intent_id status=$status"
