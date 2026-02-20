#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

missing=0

require_dir() {
  local path="$1"
  if [[ ! -d "${path}" ]]; then
    echo "[MISSING DIR] ${path}"
    missing=1
  fi
}

require_file() {
  local path="$1"
  if [[ ! -f "${path}" ]]; then
    echo "[MISSING FILE] ${path}"
    missing=1
  fi
}

forbidden_path() {
  local path="$1"
  if [[ -e "${path}" ]]; then
    echo "[FORBIDDEN PATH EXISTS] ${path}"
    missing=1
  fi
}

echo "== Required directories =="
require_dir ".github/workflows"
require_dir "contracts"
require_dir "docs"
require_dir "LOGS"

echo "== Required root files =="
require_file "README.md"
require_file "REPOS.md"
require_file "MASTER_CONTEXT.md"
require_file "DECISIONS.md"
require_file "CONTRIBUTING.md"
require_file "SECURITY.md"
require_file "PROJECT_STORY_FOR_HUMANS.md"
require_file ".gitignore"

echo "== Forbidden runtime paths =="
forbidden_path "codex"
forbidden_path "codex-engine"
forbidden_path "mcp"
forbidden_path "scripts"
forbidden_path "_archive"

echo "== Sweep check =="
if ! bash tools/repo_sweep.sh --strict; then
  echo "[FAIL] tools/repo_sweep.sh --strict failed."
  exit 2
fi

if [[ "${missing}" -ne 0 ]]; then
  echo "[FAIL] ai-governance final check failed."
  exit 1
fi

echo "[PASS] ai-governance final check passed."
