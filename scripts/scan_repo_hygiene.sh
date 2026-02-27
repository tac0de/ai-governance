#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
errors=0

TMP_MAX_FILE_BYTES=262144
ENABLE_TMP_SENSITIVE_KEYWORD_GUARD=0

ALLOWED_ROOT_DIRS=(
  ".git"
  ".github"
  "control"
  "docs"
  "fixtures"
  "policies"
  "schemas"
  "scripts"
  "services"
  "traces"
)

fail() {
  local rel_path="$1"
  local message="$2"
  echo "VALIDATION_ERROR ${rel_path}: ${message}" >&2
  errors=$((errors + 1))
}

is_in_list() {
  local candidate="$1"
  shift
  local allowed
  for allowed in "$@"; do
    if [[ "$candidate" == "$allowed" ]]; then
      return 0
    fi
  done
  return 1
}

matches_any_pattern() {
  local candidate="$1"
  shift
  local pattern
  for pattern in "$@"; do
    if [[ "$candidate" == $pattern ]]; then
      return 0
    fi
  done
  return 1
}

scan_root_shape() {
  local dir_path
  local dir_name

  while IFS= read -r dir_path; do
    dir_name="$(basename "$dir_path")"
    if ! is_in_list "$dir_name" "${ALLOWED_ROOT_DIRS[@]}"; then
      fail "$dir_name" "root directory not allowed by fixed shape"
    fi
  done < <(find "$ROOT_DIR" -mindepth 1 -maxdepth 1 -type d | sort)
}

scan_root_shape

if (( errors > 0 )); then
  exit 1
fi

echo "REPO_HYGIENE_PASS"
