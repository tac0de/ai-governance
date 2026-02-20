#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

BASE_SHA="${1:-}"
HEAD_SHA="${2:-HEAD}"

ALLOWED_REGEX='^((\.github|contracts|docs|LOGS|tools|config|\.archive|\.vscode)/.+|README\.md|REPOS\.md|MASTER_CONTEXT\.md|DECISIONS\.md|CONTRIBUTING\.md|SECURITY\.md|PROJECT_STORY_FOR_HUMANS\.md|\.gitignore|\.env\.example)$'

if [[ -n "${BASE_SHA}" && "${BASE_SHA}" != "0000000000000000000000000000000000000000" ]]; then
  CHANGED_STATUS="$(git diff --name-status "${BASE_SHA}" "${HEAD_SHA}")"
else
  echo "[control-plane-guard] Missing base SHA; scanning HEAD commit only."
  CHANGED_STATUS="$(git show --pretty="" --name-status "${HEAD_SHA}")"
fi

if [[ -z "${CHANGED_STATUS}" ]]; then
  echo "[control-plane-guard] PASS (no changed files)."
  exit 0
fi

violations=""
while IFS=$'\t' read -r status path1 path2; do
  [[ -z "${status:-}" ]] && continue

  if [[ "${status}" == D* ]]; then
    continue
  fi

  target_path="${path1}"
  if [[ "${status}" == R* || "${status}" == C* ]]; then
    target_path="${path2:-${path1}}"
  fi

  if [[ -z "${target_path}" ]]; then
    continue
  fi

  if ! [[ "${target_path}" =~ ${ALLOWED_REGEX} ]]; then
    violations+="${status}"$'\t'"${target_path}"$'\n'
  fi
done <<< "${CHANGED_STATUS}"

if [[ -n "${violations}" ]]; then
  echo "[control-plane-guard] ERROR: non-control-plane paths changed."
  echo "${violations}"
  echo "[control-plane-guard] Allowed roots: .github/, contracts/, docs/, LOGS/, tools/, config/, .archive/, .vscode/"
  exit 1
fi

echo "[control-plane-guard] PASS"
