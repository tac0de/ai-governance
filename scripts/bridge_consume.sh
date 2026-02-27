#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE' >&2
Usage:
  bridge_consume.sh [bridge_dir] [executor_out_dir] [--executor <executor_id>]

Defaults:
  bridge_dir: traces/bridge
  executor: codex
  executor_out_dir: traces/executor-queue/<executor>
USAGE
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bridge_dir="$ROOT_DIR/traces/bridge"
executor="codex"
executor_out_dir=""

positional=()
while (( $# > 0 )); do
  case "$1" in
    --executor)
      if (( $# < 2 )); then
        usage
        exit 1
      fi
      executor="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      positional+=("$1")
      shift
      ;;
  esac
done

if (( ${#positional[@]} > 2 )); then
  usage
  exit 1
fi
if (( ${#positional[@]} >= 1 )); then
  bridge_dir="${positional[0]}"
fi
if (( ${#positional[@]} == 2 )); then
  executor_out_dir="${positional[1]}"
fi
if [[ -z "$executor_out_dir" ]]; then
  executor_out_dir="$ROOT_DIR/traces/executor-queue/$executor"
fi

action_ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing command: $1" >&2; exit 1; }
}

hash_file() {
  local p="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$p" | awk '{print $1}'
  else
    shasum -a 256 "$p" | awk '{print $1}'
  fi
}

sanitize_id() {
  printf '%s' "$1" | tr -c 'a-zA-Z0-9._-' '-'
}

require jq

if ! jq -e --arg id "$executor" '
  [
    (.allowed_executors_by_tier.low[]?),
    (.allowed_executors_by_tier.medium[]?),
    (.allowed_executors_by_tier.high[]?),
    (.fallback_chain[]?)
  ] | any(.==$id)
' "$ROOT_DIR/policies/agent_routing_policy.v0.1.json" >/dev/null 2>&1; then
  echo "EXECUTOR_NOT_ALLOWED_BY_POLICY executor=$executor" >&2
  exit 1
fi

mkdir -p "$bridge_dir"/{dispatched,consumed,logs}
mkdir -p "$executor_out_dir"

consumed_count=0

shopt -s nullglob
for dispatch_path in "$bridge_dir"/dispatched/*.dispatch.json; do
  [[ -f "$dispatch_path" ]] || continue

  if ! jq -e '
    (.intent_id|type=="string" and length>0) and
    (.intent_ref|type=="string" and test("^[a-f0-9]{64}$")) and
    (.target_executor|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
    (.objective|type=="string" and length>0) and
    (.constraints|type=="array") and
    (.evidence_refs|type=="array") and
    (.submitted_at|type=="string" and length>0)
  ' "$dispatch_path" >/dev/null 2>&1; then
    echo "DISPATCH_SCHEMA_FAIL path=$dispatch_path" >&2
    continue
  fi

  target_executor="$(jq -r '.target_executor' "$dispatch_path")"
  if [[ "$target_executor" != "$executor" ]]; then
    continue
  fi

  intent_id="$(jq -r '.intent_id' "$dispatch_path")"
  safe_intent_id="$(sanitize_id "$intent_id")"
  dispatch_ref="$(hash_file "$dispatch_path")"
  consumed_path="$bridge_dir/consumed/${safe_intent_id}.consumed.json"

  if [[ -f "$consumed_path" ]]; then
    prev_ref="$(jq -r '.dispatch_ref // ""' "$consumed_path")"
    if [[ "$prev_ref" == "$dispatch_ref" ]]; then
      continue
    fi
  fi

  task_file="$executor_out_dir/executor-task-${safe_intent_id}.json"

  jq -cn \
    --arg created_at "$action_ts" \
    --arg source_repo "ai-governance" \
    --arg source_dispatch_path "${dispatch_path#$ROOT_DIR/}" \
    --arg source_dispatch_ref "$dispatch_ref" \
    --arg target_executor "$target_executor" \
    --arg intent_id "$(jq -r '.intent_id' "$dispatch_path")" \
    --arg intent_ref "$(jq -r '.intent_ref' "$dispatch_path")" \
    --arg objective "$(jq -r '.objective' "$dispatch_path")" \
    --arg submitted_at "$(jq -r '.submitted_at' "$dispatch_path")" \
    --argjson constraints "$(jq -c '.constraints' "$dispatch_path")" \
    --argjson evidence_refs "$(jq -c '.evidence_refs' "$dispatch_path")" \
    '{
      version:"v0.1",
      created_at:$created_at,
      source:{repo:$source_repo,dispatch_path:$source_dispatch_path,dispatch_ref:$source_dispatch_ref},
      intent:{intent_id:$intent_id,intent_ref:$intent_ref,objective:$objective,submitted_at:$submitted_at,constraints:$constraints,evidence_refs:$evidence_refs,target_executor:$target_executor},
      status:"queued"
    }' > "$task_file"

  jq -cn \
    --arg intent_id "$intent_id" \
    --arg consumed_at "$action_ts" \
    --arg dispatch_ref "$dispatch_ref" \
    --arg executor "$executor" \
    --arg task_path "$task_file" \
    '{intent_id:$intent_id,consumed_at:$consumed_at,dispatch_ref:$dispatch_ref,executor:$executor,task_path:$task_path}' > "$consumed_path"

  jq -cn \
    --arg ts "$action_ts" \
    --arg event "dispatch_consumed" \
    --arg intent_id "$intent_id" \
    --arg dispatch_ref "$dispatch_ref" \
    --arg executor "$executor" \
    --arg task_path "$task_file" \
    '{ts:$ts,event:$event,intent_id:$intent_id,dispatch_ref:$dispatch_ref,executor:$executor,task_path:$task_path}' \
    >> "$bridge_dir/logs/events.jsonl"

  consumed_count=$((consumed_count + 1))
done

echo "CONSUME_OK count=$consumed_count out_dir=$executor_out_dir"
