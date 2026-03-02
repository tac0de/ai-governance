#!/usr/bin/env bash
set -euo pipefail

# Legacy compatibility bootstrap only.
# New linked-service onboarding should use service-root kernel contracts, not seed expansion.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICES_REG_REL="control/registry/services.v0.1.json"
LEGACY_BOOTSTRAP_APPROVED="${LEGACY_SEED_BOOTSTRAP_APPROVED:-0}"

service_id=""
service_name=""
bootstrap_profile="standard"
risk_tier="medium"
policy_profile="balanced"
output_dir=""
seed_source="none"
include_prompt_strategy="true"
include_plan_strategy="true"
init_git="true"

require() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing command: $1" >&2
    exit 1
  }
}

usage() {
  echo "Usage: LEGACY_SEED_BOOTSTRAP_APPROVED=1 $0 --service-id <id> --service-name <name> --output-dir <path> [--bootstrap-profile <standard|ritual-uiux>] [--risk-tier <low|medium|high>] [--policy-profile <strict|balanced|creative>] [--seed-source <catalog-id|none>] [--include-prompt-strategy <true|false>] [--include-plan-strategy <true|false>] [--init-git <true|false>]" >&2
  exit 1
}

is_true_false() {
  [[ "$1" == "true" || "$1" == "false" ]]
}

sha_file() {
  local target="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$target" | awk '{print $1}'
  else
    shasum -a 256 "$target" | awk '{print $1}'
  fi
}

render_readme() {
  local template_rel="$1"
  local service_name_value="$2"
  local output_path="$3"
  local title
  title="$(jq -r --arg service_name "$service_name_value" '.title_template | gsub("\\{\\{service_name\\}\\}"; $service_name)' "$ROOT_DIR/$template_rel")"
  {
    printf '# %s\n\n' "$title"
    while IFS=$'\t' read -r heading body; do
      printf '## %s\n\n%s\n\n' "$heading" "$body"
    done < <(jq -r '.sections[] | [.heading, .body] | @tsv' "$ROOT_DIR/$template_rel")
  } > "$output_path"
}

if [[ $# -eq 0 ]]; then
  usage
fi

if [[ "$LEGACY_BOOTSTRAP_APPROVED" != "1" ]]; then
  echo "LEGACY_BOOTSTRAP_DISABLED use control/registry/linked-services.v0.5.json, control/registry/service-kernel.v0.5.json, and control/registry/temporary-links.v0.5.json instead" >&2
  echo "To use this script intentionally for seed-era compatibility, run with LEGACY_SEED_BOOTSTRAP_APPROVED=1." >&2
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --service-id)
      service_id="${2:-}"
      shift 2
      ;;
    --service-name)
      service_name="${2:-}"
      shift 2
      ;;
    --bootstrap-profile)
      bootstrap_profile="${2:-}"
      shift 2
      ;;
    --risk-tier)
      risk_tier="${2:-}"
      shift 2
      ;;
    --policy-profile)
      policy_profile="${2:-}"
      shift 2
      ;;
    --output-dir)
      output_dir="${2:-}"
      shift 2
      ;;
    --seed-source)
      seed_source="${2:-}"
      shift 2
      ;;
    --include-prompt-strategy)
      include_prompt_strategy="${2:-}"
      shift 2
      ;;
    --include-plan-strategy)
      include_plan_strategy="${2:-}"
      shift 2
      ;;
    --init-git)
      init_git="${2:-}"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

require jq

[[ -n "$service_id" && -n "$service_name" && -n "$output_dir" ]] || usage

if ! [[ "$service_id" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "INVALID_SERVICE_ID" >&2
  exit 1
fi

case "$bootstrap_profile" in
  standard|ritual-uiux) ;;
  *)
    echo "INVALID_BOOTSTRAP_PROFILE" >&2
    exit 1
    ;;
esac

case "$risk_tier" in
  low|medium|high) ;;
  *)
    echo "INVALID_RISK_TIER" >&2
    exit 1
    ;;
esac

case "$policy_profile" in
  strict|balanced|creative) ;;
  *)
    echo "INVALID_POLICY_PROFILE" >&2
    exit 1
    ;;
esac

is_true_false "$include_prompt_strategy" || { echo "INVALID_INCLUDE_PROMPT_STRATEGY" >&2; exit 1; }
is_true_false "$include_plan_strategy" || { echo "INVALID_INCLUDE_PLAN_STRATEGY" >&2; exit 1; }
is_true_false "$init_git" || { echo "INVALID_INIT_GIT" >&2; exit 1; }

if [[ "$init_git" == "true" ]]; then
  require git
fi

if [[ "$bootstrap_profile" == "ritual-uiux" && "$seed_source" == "none" ]]; then
  seed_source="thedivineparadox"
fi

seed_source_ref_value="none"
if [[ "$seed_source" != "none" ]]; then
  seed_source_ref_value="catalog:$seed_source"
fi

seed_contract_bundle_ref=""
seed_agent_roles_ref=""
seed_agent_handoffs_ref=""
seed_mcp_allowlist_ref=""
seed_slo_contract_ref=""

if [[ "$seed_source" != "none" ]]; then
  if [[ ! -f "$ROOT_DIR/$SERVICES_REG_REL" ]]; then
    echo "SEED_CATALOG_MISSING" >&2
    exit 1
  fi
  if ! jq -e --arg seed_source "$seed_source" '.services | any(.id==$seed_source)' "$ROOT_DIR/$SERVICES_REG_REL" >/dev/null 2>&1; then
    echo "UNKNOWN_SEED_SOURCE $seed_source" >&2
    exit 1
  fi
  seed_profile="$(jq -r --arg seed_source "$seed_source" '.services[] | select(.id==$seed_source) | .bootstrap_profile' "$ROOT_DIR/$SERVICES_REG_REL")"
  if [[ "$seed_profile" != "$bootstrap_profile" ]]; then
    echo "SEED_PROFILE_MISMATCH expected=$bootstrap_profile actual=$seed_profile" >&2
    exit 1
  fi
  seed_contract_bundle_ref="$(jq -r --arg seed_source "$seed_source" '.services[] | select(.id==$seed_source) | .contract_bundle_ref' "$ROOT_DIR/$SERVICES_REG_REL")"
  seed_agent_roles_ref="$(jq -r --arg seed_source "$seed_source" '.services[] | select(.id==$seed_source) | .agent_roles_ref' "$ROOT_DIR/$SERVICES_REG_REL")"
  seed_agent_handoffs_ref="$(jq -r --arg seed_source "$seed_source" '.services[] | select(.id==$seed_source) | .agent_handoffs_ref' "$ROOT_DIR/$SERVICES_REG_REL")"
  seed_mcp_allowlist_ref="$(jq -r --arg seed_source "$seed_source" '.services[] | select(.id==$seed_source) | .default_mcp_allowlist_ref' "$ROOT_DIR/$SERVICES_REG_REL")"
  seed_slo_contract_ref="$(jq -r --arg seed_source "$seed_source" '.services[] | select(.id==$seed_source) | .default_slo_contract_ref' "$ROOT_DIR/$SERVICES_REG_REL")"
fi

if [[ -e "$output_dir" ]] && find "$output_dir" -mindepth 1 -maxdepth 1 | read -r _; then
  echo "OUTPUT_DIR_NOT_EMPTY $output_dir" >&2
  exit 1
fi

mkdir -p "$output_dir/governance/agent-roles"

manifest_json="$(jq -c \
  --arg service_id "$service_id" \
  --arg service_name "$service_name" \
  --arg bootstrap_profile "$bootstrap_profile" \
  --arg risk_tier "$risk_tier" \
  --arg policy_profile "$policy_profile" \
  --argjson include_prompt_strategy "$include_prompt_strategy" \
  --argjson include_plan_strategy "$include_plan_strategy" \
  --argjson init_git "$init_git" \
  --arg seed_source_ref "$seed_source_ref_value" \
  '.service_id=$service_id
   | .service_name=$service_name
   | .bootstrap_profile=$bootstrap_profile
   | .risk_tier=$risk_tier
   | .policy_profile=$policy_profile
   | .include_prompt_strategy=$include_prompt_strategy
   | .include_plan_strategy=$include_plan_strategy
   | .init_git=$init_git
   | .seed_source_ref=$seed_source_ref' \
  "$ROOT_DIR/control/templates/service-bootstrap/bootstrap.manifest.template.v0.1.json")"
printf '%s\n' "$manifest_json" > "$output_dir/governance/bootstrap.manifest.v0.1.json"
manifest_hash="$(bash "$ROOT_DIR/scripts/hash_ref.sh" "$output_dir/governance/bootstrap.manifest.v0.1.json")"

contract_json="$(jq -c \
  --arg service_id "$service_id" \
  --arg service_name "$service_name" \
  --arg risk_tier "$risk_tier" \
  --argjson include_prompt_strategy "$include_prompt_strategy" \
  --argjson include_plan_strategy "$include_plan_strategy" \
  '.service_id=$service_id
   | .summary=("Bootstrap-generated governance contract for " + $service_name + ".")
   | .purpose=("Define the portable governance kit for " + $service_name + ".")
   | .risk.tier=$risk_tier
   | .governance_scope.primary_users=["service owners","governance maintainers"]
   | .governance_scope.dependencies=(
       [
         "governance/bootstrap.manifest.v0.1.json",
         "governance/policy.profile.json",
         "governance/mcp.allowlist.json",
         "governance/slo.contract.v0.1.json",
         "governance/agent-roles/agent.roles.v0.1.json",
         "governance/agent-roles/agent.handoffs.v0.1.json"
       ]
       + (if $include_prompt_strategy then ["governance/prompt.strategy.v0.1.json"] else [] end)
       + (if $include_plan_strategy then ["governance/plan.strategy.v0.1.json"] else [] end)
     )
   | .integrations.governance_interfaces=(
       [
         "governance/bootstrap.manifest.v0.1.json",
         "governance/policy.profile.json"
       ]
       + (if $include_prompt_strategy then ["governance/prompt.strategy.v0.1.json"] else [] end)
       + (if $include_plan_strategy then ["governance/plan.strategy.v0.1.json"] else [] end)
     )' \
  "$ROOT_DIR/control/templates/service-bootstrap/service.contract.bundle.template.v0.1.json")"
printf '%s\n' "$contract_json" > "$output_dir/governance/service.contract.bundle.v0.1.json"

policy_json="$(jq -cn \
  --arg policy_profile "$policy_profile" \
  '{
    policy_profile:$policy_profile,
    governance_path:"service-local",
    notes:[
      "Portable local governance profile generated by ai-governance v0.3.",
      "This service can operate without ai-governance at runtime."
    ]
  }')"
printf '%s\n' "$policy_json" > "$output_dir/governance/policy.profile.json"

if [[ -n "$seed_mcp_allowlist_ref" ]]; then
  allowlist_json="$(jq -c --arg service_id "$service_id" '.service_id=$service_id' "$ROOT_DIR/$seed_mcp_allowlist_ref")"
else
  allowlist_json="$(jq -cn --arg service_id "$service_id" '{service_id:$service_id, allowed_mcps:[]}')"
fi
printf '%s\n' "$allowlist_json" > "$output_dir/governance/mcp.allowlist.json"

if [[ -n "$seed_slo_contract_ref" ]]; then
  cp "$ROOT_DIR/$seed_slo_contract_ref" "$output_dir/governance/slo.contract.v0.1.json"
else
  cp "$ROOT_DIR/services/gongvue/slo.contract.v0.1.json" "$output_dir/governance/slo.contract.v0.1.json"
fi

if [[ "$bootstrap_profile" == "ritual-uiux" ]]; then
  roles_json="$(jq -c \
    --arg service_id "$service_id" \
    --argjson include_prompt_strategy "$include_prompt_strategy" \
    --argjson include_plan_strategy "$include_plan_strategy" \
    '.service_id=$service_id
     | .governance_source_refs=[
         "governance/service.contract.bundle.v0.1.json",
         "governance/policy.profile.json"
       ]
     | .roles |= map(
         .policy_refs=["governance/policy.profile.json"]
         | .output_contract_refs=(
             (if $include_plan_strategy then ["governance/plan.strategy.v0.1.json"] else ["governance/bootstrap.manifest.v0.1.json"] end)
             + (if $include_prompt_strategy and .role_id=="ux-research-cell" then ["governance/prompt.strategy.v0.1.json"] else [] end)
           )
       )' \
    "$ROOT_DIR/$seed_agent_roles_ref")"
  handoffs_json="$(jq -c \
    --arg service_id "$service_id" \
    '.service_id=$service_id
     | .handoffs |= map(.required_policy_ref="governance/policy.profile.json")' \
    "$ROOT_DIR/$seed_agent_handoffs_ref")"
else
  roles_json="$(jq -c \
    --arg service_id "$service_id" \
    --argjson include_plan_strategy "$include_plan_strategy" \
    '.service_id=$service_id
     | .governance_source_refs=[
         "governance/service.contract.bundle.v0.1.json",
         "governance/policy.profile.json"
       ]
     | .roles |= map(
         .output_contract_refs=(if $include_plan_strategy then ["governance/plan.strategy.v0.1.json"] else ["governance/bootstrap.manifest.v0.1.json"] end)
       )' \
    "$ROOT_DIR/control/templates/service-bootstrap/agent.roles.template.v0.1.json")"
  handoffs_json="$(jq -c \
    --arg service_id "$service_id" \
    '.service_id=$service_id' \
    "$ROOT_DIR/control/templates/service-bootstrap/agent.handoffs.template.v0.1.json")"
fi

printf '%s\n' "$roles_json" > "$output_dir/governance/agent-roles/agent.roles.v0.1.json"
printf '%s\n' "$handoffs_json" > "$output_dir/governance/agent-roles/agent.handoffs.v0.1.json"

if [[ "$include_prompt_strategy" == "true" ]]; then
  if [[ "$bootstrap_profile" == "ritual-uiux" ]]; then
    prompt_json="$(jq -cn \
      --arg service_id "$service_id" \
      --arg strategy_mode "$bootstrap_profile" \
      --argjson roles "$(jq -c '.roles' "$output_dir/governance/agent-roles/agent.roles.v0.1.json")" \
      '{
        version:"v0.1",
        service_id:$service_id,
        strategy_mode:$strategy_mode,
        roles: ($roles | map({
          role_id:.role_id,
          prompt_mode:(if .role_id=="ux-research-cell" then "ux-evidence-briefing" elif .role_id=="visual-systems-cell" then "visual-modulation-briefing" else "governed-role-execution" end),
          allowed_prompt_scopes:(if .role_id=="ux-research-cell" then ["ui-ux-evidence","execution-planning"] else ["bounded-change-planning","policy-aligned-review"] end),
          forbidden_prompt_patterns:["runtime-code-generation","policy-bypass","untracked-external-dependency"],
          required_refs:["governance/policy.profile.json"]
        })),
        global_guardrails:[
          "Prompt execution must preserve deterministic evidence references.",
          "Prompt execution must not rely on ai-governance relative paths."
        ]
      }')"
  else
    prompt_json="$(jq -c \
      --arg service_id "$service_id" \
      '.service_id=$service_id' \
      "$ROOT_DIR/control/templates/service-bootstrap/prompt.strategy.template.v0.1.json")"
  fi
  printf '%s\n' "$prompt_json" > "$output_dir/governance/prompt.strategy.v0.1.json"
fi

if [[ "$include_plan_strategy" == "true" ]]; then
  if [[ "$bootstrap_profile" == "ritual-uiux" ]]; then
    if [[ -f "$ROOT_DIR/services/thedivineparadox/agent-roles/uiux.execution-plan.v0.1.json" ]]; then
      plan_json="$(jq -c \
        --arg service_id "$service_id" \
        '{
          version:"v0.1",
          service_id:$service_id,
          strategy_mode:"ritual-uiux",
          phase_templates:(.phases | map({
            phase_id:.phase_id,
            title:.title,
            owner_role_id:.owner_role_id,
            required_output_kinds:(.deliverables | map(.output_kind) | unique),
            default_acceptance_checks:.acceptance_checks
          })),
          release_gate_defaults:{
            owner_role_id:.release_gate.owner_role_id,
            required_inputs:.release_gate.required_inputs,
            blocking_conditions:.release_gate.blocking_conditions
          }
        }' \
        "$ROOT_DIR/services/thedivineparadox/agent-roles/uiux.execution-plan.v0.1.json")"
    else
      plan_json="$(jq -c \
        --arg service_id "$service_id" \
        '.service_id=$service_id | .strategy_mode="ritual-uiux"' \
        "$ROOT_DIR/control/templates/service-bootstrap/plan.strategy.template.v0.1.json")"
    fi
  else
    plan_json="$(jq -c \
      --arg service_id "$service_id" \
      '.service_id=$service_id' \
      "$ROOT_DIR/control/templates/service-bootstrap/plan.strategy.template.v0.1.json")"
  fi
  printf '%s\n' "$plan_json" > "$output_dir/governance/plan.strategy.v0.1.json"
fi

render_readme "control/templates/service-bootstrap/repo.readme.template.v0.1.json" "$service_name" "$output_dir/README.md"
printf '%s\n' ".DS_Store" > "$output_dir/.gitignore"

output_prefix="${output_dir%/}/"
artifact_tmp="$(mktemp)"
while IFS= read -r file_path; do
  rel_path="${file_path#$output_prefix}"
  file_hash="$(sha_file "$file_path")"
  kind="file"
  case "$rel_path" in
    README.md) kind="readme" ;;
    .gitignore) kind="gitignore" ;;
    governance/bootstrap.manifest.v0.1.json) kind="bootstrap-manifest" ;;
    governance/service.contract.bundle.v0.1.json) kind="service-contract" ;;
    governance/policy.profile.json) kind="policy-profile" ;;
    governance/mcp.allowlist.json) kind="mcp-allowlist" ;;
    governance/slo.contract.v0.1.json) kind="slo-contract" ;;
    governance/agent-roles/agent.roles.v0.1.json) kind="agent-roles" ;;
    governance/agent-roles/agent.handoffs.v0.1.json) kind="agent-handoffs" ;;
    governance/prompt.strategy.v0.1.json) kind="prompt-strategy" ;;
    governance/plan.strategy.v0.1.json) kind="plan-strategy" ;;
  esac
  jq -cn --arg path "$rel_path" --arg sha256 "$file_hash" --arg kind "$kind" '{path:$path, sha256:$sha256, kind:$kind}' >> "$artifact_tmp"
done < <(find "$output_dir" -type f ! -name 'bootstrap.receipt.v0.1.json' | LC_ALL=C sort)
artifact_entries="$(jq -cs '.' "$artifact_tmp")"
rm -f "$artifact_tmp"

receipt_json="$(jq -c \
  --arg service_id "$service_id" \
  --arg bootstrap_manifest_ref "$manifest_hash" \
  --argjson generated_artifacts "$artifact_entries" \
  --argjson git_initialized "$init_git" \
  --arg seed_profile "$bootstrap_profile" \
  --arg seed_source "$seed_source" \
  '.service_id=$service_id
   | .bootstrap_manifest_ref=$bootstrap_manifest_ref
   | .generated_artifacts=$generated_artifacts
   | .git_initialized=$git_initialized
   | .seed_profile=$seed_profile
   | .notes=[
       ("Seed source: " + $seed_source),
       "Generated by ai-governance v0.3 bootstrap compiler."
     ]' \
  "$ROOT_DIR/control/templates/service-bootstrap/bootstrap.receipt.template.v0.1.json")"
printf '%s\n' "$receipt_json" > "$output_dir/governance/bootstrap.receipt.v0.1.json"

if [[ "$init_git" == "true" ]]; then
  git -C "$output_dir" init -q
fi

echo "BOOTSTRAP_OK output=$output_dir service_id=$service_id profile=$bootstrap_profile seed_source=$seed_source"
