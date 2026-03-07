#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOOP_PATH="${ROOT_DIR}/docs/version-upgrade-loop.json"
REGISTRY_PATH="${ROOT_DIR}/docs/role-prompt-registry.json"
PROPOSAL_PATH="${ROOT_DIR}/docs/version-upgrade-proposal.json"
SOLUTION_PACKAGING_PATH="${ROOT_DIR}/control/registry/solution-packaging.v0.8.json"
COGNITIVE_DEBT_PATH="${ROOT_DIR}/control/registry/cognitive-debt-ledger.v0.8.json"
SPECIALIST_MCP_PATH="${ROOT_DIR}/control/registry/specialist-mcp-registry.v0.8.json"
MONITORING_LINK_PATH="${ROOT_DIR}/control/registry/monitoring-link.v0.8.json"
SOLUTION_SURFACE_PATH="${ROOT_DIR}/docs/solution-packaging-surface.json"
DEBT_SURFACE_PATH="${ROOT_DIR}/docs/cognitive-debt-surface.json"
SPECIALIST_SURFACE_PATH="${ROOT_DIR}/docs/specialist-mcp-surface.json"
MONITORING_SURFACE_PATH="${ROOT_DIR}/docs/monitoring-link-surface.json"

require() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing command: $1" >&2
    exit 1
  }
}

require jq

if [[ ! -f "${LOOP_PATH}" || ! -f "${REGISTRY_PATH}" || ! -f "${SOLUTION_PACKAGING_PATH}" || ! -f "${COGNITIVE_DEBT_PATH}" || ! -f "${SPECIALIST_MCP_PATH}" || ! -f "${MONITORING_LINK_PATH}" ]]; then
  echo "Missing docs evolution inputs." >&2
  exit 1
fi

current_version="$(awk '/^# ai-governance v/{print $3; exit}' "${ROOT_DIR}/README.md")"
if [[ -z "${current_version}" ]]; then
  echo "Could not infer current version from README.md" >&2
  exit 1
fi

ensure_prompt_file() {
  local prompt_path="$1"
  local prompt_id="$2"

  if [[ -f "${prompt_path}" ]]; then
    return
  fi

  mkdir -p "$(dirname "${prompt_path}")"

  case "${prompt_id}" in
    landing-narrative)
      cat <<'EOF' > "${prompt_path}"
# Landing Narrative

Write the landing like a versioned worldview with clear release truth.
EOF
      ;;
    role-system)
      cat <<'EOF' > "${prompt_path}"
# Role System

Explain how contracts, prompts, and operator sovereignty stay aligned.
EOF
      ;;
    visual-direction)
      cat <<'EOF' > "${prompt_path}"
# Visual Direction

Push the visual language beyond generic SaaS while keeping the interface readable.
EOF
      ;;
    release-reflection)
      cat <<'EOF' > "${prompt_path}"
# Release Reflection

Explain why the version closes and what the next version should challenge.
EOF
      ;;
    mission-control-experience)
      cat <<'EOF' > "${prompt_path}"
# Mission Control Experience

Keep the landing feeling like a live operator console with disciplined information hierarchy.
EOF
      ;;
    cognitive-debt-analyst)
      cat <<'EOF' > "${prompt_path}"
# Cognitive Debt Analyst

Translate agent risk into explicit debt items with enterprise decision value.
EOF
      ;;
    specialist-mcp-composer)
      cat <<'EOF' > "${prompt_path}"
# Specialist MCP Composer

Describe which specialist MCPs should be composed and why.
EOF
      ;;
    solution-packaging-narrative)
      cat <<'EOF' > "${prompt_path}"
# Solution Packaging Narrative

Explain the tiered offer as operating commitments rather than vague package labels.
EOF
      ;;
    *)
      cat <<EOF > "${prompt_path}"
# ${prompt_id}

Prompt content pending.
EOF
      ;;
  esac
}

while IFS=$'\t' read -r prompt_id prompt_rel; do
  ensure_prompt_file "${ROOT_DIR}/${prompt_rel}" "${prompt_id}"
done < <(jq -r '.prompts[] | [.prompt_id, .path] | @tsv' "${REGISTRY_PATH}")

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

jq -n \
  --arg current_version "${current_version}" \
  --arg control_plane_boundary "$(jq -r '.control_plane_boundary[0]' "${SOLUTION_PACKAGING_PATH}")" \
  --argjson tiers "$(jq '[.tiers[] | {
    tier_id,
    label,
    link_mode,
    input_count: (.required_inputs | length),
    output_count: (.generated_outputs | length),
    receipt_count: (.required_receipts | length),
    handoff_conditions
  }]' "${SOLUTION_PACKAGING_PATH}")" \
  '{
    current_version: $current_version,
    surface_id: "solution-packaging-surface",
    control_plane_boundary: $control_plane_boundary,
    tiers: $tiers
  }' > "${SOLUTION_SURFACE_PATH}"

jq -n \
  --arg current_version "${current_version}" \
  --argjson decision_states "$(jq '.decision_states' "${COGNITIVE_DEBT_PATH}")" \
  --argjson debt_classes "$(jq '[.debt_classes[] | {
    debt_id,
    title,
    impact,
    signal_count: (.observability_signals | length),
    mitigation_count: (.mitigation | length)
  }]' "${COGNITIVE_DEBT_PATH}")" \
  '{
    current_version: $current_version,
    surface_id: "cognitive-debt-surface",
    decision_states: $decision_states,
    debt_classes: $debt_classes
  }' > "${DEBT_SURFACE_PATH}"

jq -n \
  --arg current_version "${current_version}" \
  --arg central_role "$(jq -r '.central_role' "${SPECIALIST_MCP_PATH}")" \
  --argjson specialists "$(jq '[.specialists[] | {
    mcp_id,
    scope_count: (.scope | length),
    allowed_data_classes,
    auth_model,
    recommended_use_cases
  }]' "${SPECIALIST_MCP_PATH}")" \
  '{
    current_version: $current_version,
    surface_id: "specialist-mcp-surface",
    central_role: $central_role,
    specialists: $specialists
  }' > "${SPECIALIST_SURFACE_PATH}"

jq -n \
  --arg current_version "${current_version}" \
  --argjson required_fields "$(jq '.required_fields' "${MONITORING_LINK_PATH}")" \
  --argjson required_receipts "$(jq '.required_receipts' "${MONITORING_LINK_PATH}")" \
  --argjson monitoring_tracks "$(jq '.monitoring_tracks' "${MONITORING_LINK_PATH}")" \
  --argjson review_cadence_values "$(jq '.review_cadence_values' "${MONITORING_LINK_PATH}")" \
  '{
    current_version: $current_version,
    surface_id: "monitoring-link-surface",
    required_fields: $required_fields,
    required_receipts: $required_receipts,
    monitoring_tracks: $monitoring_tracks,
    review_cadence_values: $review_cadence_values
  }' > "${MONITORING_SURFACE_PATH}"

echo "DOCS_EVOLUTION_PROPOSAL_UPDATED ${PROPOSAL_PATH}"
echo "DOCS_EVOLUTION_SURFACE_UPDATED ${SOLUTION_SURFACE_PATH}"
echo "DOCS_EVOLUTION_SURFACE_UPDATED ${DEBT_SURFACE_PATH}"
echo "DOCS_EVOLUTION_SURFACE_UPDATED ${SPECIALIST_SURFACE_PATH}"
echo "DOCS_EVOLUTION_SURFACE_UPDATED ${MONITORING_SURFACE_PATH}"
