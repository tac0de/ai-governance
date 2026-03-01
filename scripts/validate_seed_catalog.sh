#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICES_REG_REL="control/registry/services.v0.1.json"
target_service=""
errors=0

if [[ $# -gt 0 ]]; then
  if [[ $# -ne 2 || "$1" != "--service" ]]; then
    echo "Usage: $0 [--service <service_id>]" >&2
    exit 1
  fi
  target_service="$2"
fi

require() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing command: $1" >&2
    exit 1
  }
}

fail() {
  local rel_path="$1"
  local message="$2"
  echo "SEED_VALIDATION_ERROR ${rel_path}: ${message}" >&2
  errors=$((errors + 1))
}

check_file() {
  local rel_path="$1"
  if [[ ! -f "$ROOT_DIR/$rel_path" ]]; then
    fail "$rel_path" "missing file"
    return 1
  fi
  return 0
}

check_dir() {
  local rel_path="$1"
  if [[ ! -d "$ROOT_DIR/$rel_path" ]]; then
    fail "$rel_path" "missing directory"
    return 1
  fi
  return 0
}

check_json() {
  local rel_path="$1"
  if ! check_file "$rel_path"; then
    return 1
  fi
  if ! jq -e . "$ROOT_DIR/$rel_path" >/dev/null 2>&1; then
    fail "$rel_path" "invalid JSON"
    return 1
  fi
  return 0
}

require jq

if ! check_json "$SERVICES_REG_REL"; then
  exit 1
fi

if [[ -n "$target_service" ]]; then
  if ! jq -e --arg target_service "$target_service" '.services | any(.id==$target_service)' "$ROOT_DIR/$SERVICES_REG_REL" >/dev/null 2>&1; then
    echo "UNKNOWN_SEED_SERVICE $target_service" >&2
    exit 1
  fi
fi

while IFS=$'\t' read -r service_id seed_path contract_bundle_ref agent_roles_ref agent_handoffs_ref default_policy_profile_ref default_mcp_allowlist_ref default_slo_contract_ref bootstrap_profile; do
  [[ -n "$service_id" ]] || continue

  check_dir "$seed_path"
  check_json "$contract_bundle_ref"
  check_json "$agent_roles_ref"
  check_json "$agent_handoffs_ref"
  check_json "$default_policy_profile_ref"
  check_json "$default_mcp_allowlist_ref"
  check_json "$default_slo_contract_ref"

  if check_json "$contract_bundle_ref"; then
    if ! jq -e --arg service_id "$service_id" '.service_id==$service_id' "$ROOT_DIR/$contract_bundle_ref" >/dev/null 2>&1; then
      fail "$contract_bundle_ref" "service_id does not match seed id '$service_id'"
    fi
  fi

  if check_json "$default_mcp_allowlist_ref"; then
    if ! jq -e --arg service_id "$service_id" '.service_id==$service_id' "$ROOT_DIR/$default_mcp_allowlist_ref" >/dev/null 2>&1; then
      fail "$default_mcp_allowlist_ref" "service_id does not match seed id '$service_id'"
    fi
  fi

  if check_json "$agent_roles_ref"; then
    if ! jq -e '
      .version=="v0.1" and
      (.service_id|type=="string" and length>0) and
      (.governance_source_refs|type=="array" and length>0) and
      (.roles|type=="array" and length>0)
    ' "$ROOT_DIR/$agent_roles_ref" >/dev/null 2>&1; then
      fail "$agent_roles_ref" "invalid seed agent roles contract"
    fi
    if ! jq -e --arg service_id "$service_id" '.service_id==$service_id' "$ROOT_DIR/$agent_roles_ref" >/dev/null 2>&1; then
      fail "$agent_roles_ref" "service_id does not match seed id '$service_id'"
    fi
  fi

  if check_json "$agent_handoffs_ref"; then
    if ! jq -e '
      .version=="v0.1" and
      (.service_id|type=="string" and length>0) and
      (.start_roles|type=="array" and length>0) and
      (.terminal_roles|type=="array" and length>0) and
      (.handoffs|type=="array" and length>0)
    ' "$ROOT_DIR/$agent_handoffs_ref" >/dev/null 2>&1; then
      fail "$agent_handoffs_ref" "invalid seed agent handoffs contract"
    fi
    if ! jq -e --arg service_id "$service_id" '.service_id==$service_id' "$ROOT_DIR/$agent_handoffs_ref" >/dev/null 2>&1; then
      fail "$agent_handoffs_ref" "service_id does not match seed id '$service_id'"
    fi
  fi

  if [[ "$bootstrap_profile" == "ritual-uiux" ]]; then
    plan_rel="$seed_path/agent-roles/uiux.execution-plan.v0.1.json"
    if ! check_json "$plan_rel"; then
      :
    elif ! jq -e --arg service_id "$service_id" '.service_id==$service_id' "$ROOT_DIR/$plan_rel" >/dev/null 2>&1; then
      fail "$plan_rel" "service_id does not match seed id '$service_id'"
    fi
  fi
done < <(
  jq -r --arg target_service "$target_service" '
    .services[]
    | select($target_service == "" or .id == $target_service)
    | [
        .id,
        .seed_path,
        .contract_bundle_ref,
        .agent_roles_ref,
        .agent_handoffs_ref,
        .default_policy_profile_ref,
        .default_mcp_allowlist_ref,
        .default_slo_contract_ref,
        .bootstrap_profile
      ]
    | @tsv
  ' "$ROOT_DIR/$SERVICES_REG_REL"
)

if (( errors > 0 )); then
  echo "SEED_VALIDATION_FAIL count=$errors" >&2
  exit 1
fi

if [[ -n "$target_service" ]]; then
  echo "SEED_VALIDATION_PASS service=$target_service"
else
  echo "SEED_VALIDATION_PASS"
fi
