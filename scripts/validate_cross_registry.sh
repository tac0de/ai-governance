#!/usr/bin/env bash
set -euo pipefail

# DEPRECATED: legacy helper for syncing against an external governed-services registry.
# Prefer running `bash scripts/validate_all.sh` (governance-core only) and keep cross-repo
# linking out of the default CI/verdict path.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
errors=0

GOVERNANCE_REGISTRY_DEFAULT="$ROOT_DIR/control/registry/services.v0.1.json"

mode="required"
governed_registry=""
governance_registry="$GOVERNANCE_REGISTRY_DEFAULT"

fail() {
  local path="$1"
  local message="$2"
  echo "VALIDATION_ERROR ${path}: ${message}" >&2
  errors=$((errors + 1))
}

require() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing command: $1" >&2
    exit 1
  }
}

usage() {
  cat <<'USAGE'
Usage:
  validate_cross_registry.sh [--mode required|auto] [--governed-registry <path>] [--governance-registry <path>]

Modes:
  required  fail when governed registry cannot be found (default)
  auto      skip with message when governed registry cannot be found
USAGE
}

resolve_governed_registry() {
  local candidates=(
    "${GOVERNED_SERVICES_REGISTRY:-}"
    "$ROOT_DIR/../governed-services/services.registry.v0.1.json"
    "$HOME/projects/governed-services/services.registry.v0.1.json"
  )
  local candidate
  for candidate in "${candidates[@]}"; do
    [[ -n "$candidate" ]] || continue
    if [[ -f "$candidate" ]]; then
      governed_registry="$candidate"
      return 0
    fi
  done
  return 1
}

check_json_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    fail "$path" "missing file"
    return 1
  fi
  if ! jq -e . "$path" >/dev/null 2>&1; then
    fail "$path" "invalid JSON"
    return 1
  fi
  return 0
}

check_registry_sets() {
  local governed_ids governance_ids id

  governed_ids="$(jq -r '.services[]?.id' "$governed_registry" | sort -u)"
  governance_ids="$(jq -r '.services[]?.id' "$governance_registry" | sort -u)"

  while IFS= read -r id; do
    [[ -n "$id" ]] || continue
    if ! jq -e --arg id "$id" '.services | any(.id==$id)' "$governance_registry" >/dev/null 2>&1; then
      fail "$governance_registry" "missing service id '$id' from governed registry"
    fi
  done <<< "$governed_ids"

  while IFS= read -r id; do
    [[ -n "$id" ]] || continue
    if ! jq -e --arg id "$id" '.services | any(.id==$id)' "$governed_registry" >/dev/null 2>&1; then
      fail "$governed_registry" "missing service id '$id' from governance registry"
    fi
  done <<< "$governance_ids"
}

check_service_paths() {
  local id repo_path repo_basename expected_governance_repo_path

  while IFS=$'\t' read -r id repo_path; do
    [[ -n "$id" ]] || continue

    if [[ ! -d "$repo_path" ]]; then
      fail "$repo_path" "service repo directory missing for service '$id'"
    fi

    repo_basename="$(basename "$repo_path")"
    if [[ "$repo_basename" != "$id" ]]; then
      fail "$repo_path" "repo path basename '$repo_basename' must equal service id '$id'"
    fi

    expected_governance_repo_path="services/${id}"
    if ! jq -e --arg id "$id" --arg repo_path "$expected_governance_repo_path" \
      '.services | any(.id==$id and .repo_path==$repo_path)' \
      "$governance_registry" >/dev/null 2>&1; then
      fail "$governance_registry" "service '$id' must map to repo_path '$expected_governance_repo_path'"
    fi

    if [[ ! -d "$ROOT_DIR/$expected_governance_repo_path" ]]; then
      fail "$ROOT_DIR/$expected_governance_repo_path" "governance service directory missing for service '$id'"
    fi
  done < <(jq -r '.services[] | [.id, .repo_path] | @tsv' "$governed_registry")
}

require jq

while (( $# > 0 )); do
  case "$1" in
    --mode)
      mode="${2:-}"
      shift 2
      ;;
    --governed-registry)
      governed_registry="${2:-}"
      shift 2
      ;;
    --governance-registry)
      governance_registry="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ "$mode" != "required" && "$mode" != "auto" ]]; then
  echo "Invalid mode: $mode" >&2
  usage >&2
  exit 1
fi

if [[ -z "$governed_registry" ]]; then
  if ! resolve_governed_registry; then
    if [[ "$mode" == "auto" ]]; then
      echo "CROSS_REGISTRY_SYNC_SKIP missing_governed_registry"
      exit 0
    fi
    fail "governed-services/services.registry.v0.1.json" "missing file (provide --governed-registry or set GOVERNED_SERVICES_REGISTRY)"
    exit 1
  fi
fi

if ! check_json_file "$governed_registry"; then
  exit 1
fi
if ! check_json_file "$governance_registry"; then
  exit 1
fi

check_registry_sets
check_service_paths

if (( errors > 0 )); then
  exit 1
fi

echo "CROSS_REGISTRY_SYNC_PASS"
