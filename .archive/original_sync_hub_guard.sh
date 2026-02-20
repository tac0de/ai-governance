#!/usr/bin/env bash
set -euo pipefail

# Original sync_hub_guard.sh archived on 2026-02-17
# This copy preserves the guard implementation that enforces
# orchestration discipline (MASTER_CONTEXT.md, DECISIONS.md, LOGS/* etc.).
#
# The live script in `scripts/sync_hub_guard.sh` has been replaced with
# a lightweight stub that points developers to the human-facing README
# and a helper script for creating compliant LOGS entries.

# Allow local bypass for human git operations. Set SKIP_SYNC_GUARD=true in your
# environment to skip checks temporarily (e.g., `export SKIP_SYNC_GUARD=true`).
if [[ "${SKIP_SYNC_GUARD:-""}" == "true" ]]; then
  # Require an additional local confirmation so CI or remote actors cannot
  # accidentally bypass the guard simply by setting the env. This makes the
  # bypass intentionally local-only: either set a git config key or create a
  # local file in your home directory.
  local_bypass_config="$(git config --global --get syncguard.bypass || true)"
  local_bypass_file="${HOME}/.sync_hub_guard_bypass"
  if [[ "${local_bypass_config}" == "true" || -f "${local_bypass_file}" ]]; then
    echo "[sync-hub-guard] BYPASS: SKIP_SYNC_GUARD=true + local confirmation present"
    echo "[sync-hub-guard] To enable locally: run 'git config --global syncguard.bypass true' or create ${local_bypass_file}'"
  else
    echo "[sync-hub-guard] SKIP_SYNC_GUARD set but no local confirmation found. Refusing to bypass."
    echo "[sync-hub-guard] To enable bypass locally, set git config: 'git config --global syncguard.bypass true' OR create file: ${local_bypass_file}" >&2
    exit 1
  fi
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

MODE="${1:-ci}"

fail() {
  echo "[sync-hub-guard] ERROR: $1"
  exit 1
}

check_required_structure() {
  [[ -f MASTER_CONTEXT.md ]] || fail "Missing required file: MASTER_CONTEXT.md"
  [[ -f DECISIONS.md ]] || fail "Missing required file: DECISIONS.md"
  [[ -d LOGS ]] || fail "Missing required directory: LOGS"

  local headings=(
    "## 0) TL;DR"
    "## 1) Active Projects"
    "## 2) Stack & Environment"
    "## 3) Constraints"
    "## 4) Risks / Security Notes"
    "## 5) Backlog"
  )

  local h
  for h in "${headings[@]}"; do
    grep -Fqx "${h}" MASTER_CONTEXT.md || fail "MASTER_CONTEXT.md missing heading: ${h}"
  done

  local first_non_empty
  first_non_empty="$(grep -m1 -E '\\S' DECISIONS.md || true)"
  [[ "${first_non_empty}" == "# DECISIONS" ]] || fail "DECISIONS.md must start with '# DECISIONS'"

  shopt -s nullglob
  local logs=(LOGS/*.md)
  shopt -u nullglob
  [[ ${#logs[@]} -gt 0 ]] || fail "LOGS/ must contain at least one .md file"

  local newest
  newest="$(ls -1t LOGS/*.md | head -n1)"

  local log_patterns=(
    "^- Date:"
    "^- Project:"
    "^- Type:"
    "^- Tags:"
    "^- Summary"
  )
  local p
  for p in "${log_patterns[@]}"; do
    grep -Eq "${p}" "${newest}" || fail "Newest log missing required header pattern: ${p}"
  done
}

check_local_rules_safety() {
  local unsafe='allow\\s+(read|write|read,\\s*write|write,\\s*read)[^;]*:\\s*if\\s*true\\s*;'
  local rules
  for rules in firestore.rules storage.rules; do
    if [[ -f "${rules}" ]] && grep -Eqi "${unsafe}" "${rules}"; then
      fail "Unsafe allow-if-true rule detected in ${rules}"
    fi
  done
}

check_orchestration_commit_discipline() {
  local staged
  staged="$(git diff --cached --name-only --diff-filter=ACMR || true)"
  [[ -n "${staged}" ]] || return 0

  if echo "${staged}" | rg -q '^(scripts/|config/|\.github/workflows/|mcp/)'; then
    echo "${staged}" | rg -q '^MASTER_CONTEXT\\.md$' || \
      fail "Orchestration change detected. Stage MASTER_CONTEXT.md in same commit."
    echo "${staged}" | rg -q '^LOGS/.+\\.md$' || \
      fail "Orchestration change detected. Stage one LOGS/*.md session note in same commit."
  fi

  if echo "${staged}" | rg -q '^(config/risk_policy\\.json|scripts/lib/control_guard\\.sh|\.github/workflows/)'; then
    echo "${staged}" | rg -q '^DECISIONS\\.md$' || \
      fail "Policy/workflow change detected. Stage DECISIONS.md in same commit."
  fi
}

check_required_structure
check_local_rules_safety

if [[ "${MODE}" == "pre-commit" ]]; then
  check_orchestration_commit_discipline
fi

echo "[sync-hub-guard] PASS"
