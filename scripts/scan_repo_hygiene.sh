#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
errors=0

TMP_MAX_FILE_BYTES=262144
ENABLE_TMP_SENSITIVE_KEYWORD_GUARD=0

ALLOWED_ROOT_DIRS=(
  ".git"
  ".github"
  "benchmark"
  "control"
  "docs"
  "fixtures"
  "mcps"
  "policies"
  "reports"
  "schemas"
  "scripts"
  "services"
  "specs"
  "tmp"
  "traces"
)

ALLOWED_TMP_PATTERNS=(
  "pm_objective_*.txt"
  "pm_intent.*.json"
  "*.intent.local.json"
  "*.mcp.request.plan.v*.md"
  "cus-*.json"
  "tdp.*.md"
)

ALLOWED_TMP_EXTENSIONS=(
  "txt"
  "md"
  "json"
)

TMP_SENSITIVE_KEYWORDS=(
  "secret"
  "token"
  "key"
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

scan_tmp_hygiene() {
  local tmp_root="$ROOT_DIR/tmp"
  local dir_path
  local rel_dir
  local file_path
  local file_name
  local ext
  local file_size
  local keyword

  if [[ ! -d "$tmp_root" ]]; then
    return
  fi

  while IFS= read -r dir_path; do
    rel_dir="${dir_path#$ROOT_DIR/}"
    fail "$rel_dir" "subdirectory not allowed in tmp hygiene gate"
  done < <(find "$tmp_root" -mindepth 1 -type d | sort)

  while IFS= read -r file_path; do
    file_name="$(basename "$file_path")"

    if [[ "$file_name" != *.* ]]; then
      fail "tmp/$file_name" "extension required; allowed extensions: txt, md, json"
      continue
    fi

    ext="${file_name##*.}"
    if ! is_in_list "$ext" "${ALLOWED_TMP_EXTENSIONS[@]}"; then
      fail "tmp/$file_name" "extension '$ext' is not allowed"
    fi

    if ! matches_any_pattern "$file_name" "${ALLOWED_TMP_PATTERNS[@]}"; then
      fail "tmp/$file_name" "filename does not match allowed tmp patterns"
    fi

    file_size="$(wc -c < "$file_path" | tr -d '[:space:]')"
    if (( file_size > TMP_MAX_FILE_BYTES )); then
      fail "tmp/$file_name" "file too large (${file_size} bytes > ${TMP_MAX_FILE_BYTES} bytes)"
    fi

    if (( ENABLE_TMP_SENSITIVE_KEYWORD_GUARD == 1 )); then
      for keyword in "${TMP_SENSITIVE_KEYWORDS[@]}"; do
        if [[ "${file_name,,}" == *"$keyword"* ]]; then
          fail "tmp/$file_name" "sensitive keyword '$keyword' is not allowed in filename"
        fi
      done
    fi
  done < <(find "$tmp_root" -mindepth 1 -maxdepth 1 -type f | sort)
}

scan_root_shape
scan_tmp_hygiene

if (( errors > 0 )); then
  exit 1
fi

echo "REPO_HYGIENE_PASS"
