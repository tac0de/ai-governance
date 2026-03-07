#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOOP_PATH="${ROOT_DIR}/docs/version-upgrade-loop.json"
REGISTRY_PATH="${ROOT_DIR}/docs/role-prompt-registry.json"
PROPOSAL_PATH="${ROOT_DIR}/docs/version-upgrade-proposal.json"

require() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing command: $1" >&2
    exit 1
  }
}

require jq

if [[ ! -f "${LOOP_PATH}" || ! -f "${REGISTRY_PATH}" ]]; then
  echo "Missing docs evolution inputs." >&2
  exit 1
fi

current_version="$(awk '/^# ai-governance v/{print $3; exit}' "${ROOT_DIR}/README.md")"
if [[ -z "${current_version}" ]]; then
  echo "Could not infer current version from README.md" >&2
  exit 1
fi

jq -n \
  --arg source_loop_id "$(jq -r '.loop_id' "${LOOP_PATH}")" \
  --arg current_version "${current_version}" \
  --arg target_version "$(jq -r '.next_target_version' "${LOOP_PATH}")" \
  --arg docs_mode "$(jq -r '.docs_mode' "${REGISTRY_PATH}")" \
  --arg generated_from "scripts/refresh_docs_evolution.sh" \
  --argjson prompts "$(jq '[.prompts[] | {
    prompt_id,
    title,
    path,
    intent: .purpose,
    linked_contracts: .linked_contracts
  }]' "${REGISTRY_PATH}")" \
  '{
    source_loop_id: $source_loop_id,
    current_version: $current_version,
    target_version: $target_version,
    status: "generated",
    docs_mode: $docs_mode,
    generated_from: $generated_from,
    proposal_items: $prompts
  }' > "${PROPOSAL_PATH}"

echo "DOCS_EVOLUTION_PROPOSAL_UPDATED ${PROPOSAL_PATH}"
