#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <output_dir>" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output_dir="$1"
errors=0

require() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing command: $1" >&2
    exit 1
  }
}

fail() {
  local rel_path="$1"
  local message="$2"
  echo "BOOTSTRAP_VALIDATION_ERROR ${rel_path}: ${message}" >&2
  errors=$((errors + 1))
}

check_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    fail "$path" "missing file"
    return 1
  fi
  return 0
}

check_json() {
  local path="$1"
  if ! check_file "$path"; then
    return 1
  fi
  if ! jq -e . "$path" >/dev/null 2>&1; then
    fail "$path" "invalid JSON"
    return 1
  fi
  return 0
}

sha_file() {
  local target="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$target" | awk '{print $1}'
  else
    shasum -a 256 "$target" | awk '{print $1}'
  fi
}

require jq

if [[ ! -d "$output_dir" ]]; then
  echo "OUTPUT_DIR_MISSING $output_dir" >&2
  exit 1
fi

readme_path="$output_dir/README.md"
gitignore_path="$output_dir/.gitignore"
manifest_path="$output_dir/governance/bootstrap.manifest.v0.1.json"
receipt_path="$output_dir/governance/bootstrap.receipt.v0.1.json"
contract_path="$output_dir/governance/service.contract.bundle.v0.1.json"
policy_path="$output_dir/governance/policy.profile.json"
allowlist_path="$output_dir/governance/mcp.allowlist.json"
slo_path="$output_dir/governance/slo.contract.v0.1.json"
roles_path="$output_dir/governance/agent-roles/agent.roles.v0.1.json"
handoffs_path="$output_dir/governance/agent-roles/agent.handoffs.v0.1.json"
prompt_path="$output_dir/governance/prompt.strategy.v0.1.json"
plan_path="$output_dir/governance/plan.strategy.v0.1.json"

check_file "$readme_path"
check_file "$gitignore_path"
check_json "$manifest_path"
check_json "$receipt_path"
check_json "$contract_path"
check_json "$policy_path"
check_json "$allowlist_path"
check_json "$slo_path"
check_json "$roles_path"
check_json "$handoffs_path"

if ! jq -e '
  .version=="v0.1" and
  (.service_id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
  (.service_name|type=="string" and length>0) and
  (.bootstrap_profile=="standard" or .bootstrap_profile=="ritual-uiux") and
  (.risk_tier=="low" or .risk_tier=="medium" or .risk_tier=="high") and
  (.policy_profile=="strict" or .policy_profile=="balanced" or .policy_profile=="creative") and
  (.include_prompt_strategy|type=="boolean") and
  (.include_plan_strategy|type=="boolean") and
  (.init_git|type=="boolean") and
  (.seed_source_ref|type=="string" and length>0) and
  (.target_repo_layout=="governance-rooted")
' "$manifest_path" >/dev/null 2>&1; then
  fail "$manifest_path" "schema validation failed (schemas/bootstrap_manifest.schema.json)"
fi

if ! jq -e '
  .version=="v0.1" and
  (.service_id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
  (.source_release_line|type=="string" and length>0) and
  (.bootstrap_manifest_ref|type=="string" and test("^[a-f0-9]{64}$")) and
  (.generated_artifacts|type=="array" and length>0) and
  (.export_mode=="folder-repo-init") and
  (.git_initialized|type=="boolean") and
  (.seed_profile=="standard" or .seed_profile=="ritual-uiux") and
  (.notes|type=="array" and length>0)
' "$receipt_path" >/dev/null 2>&1; then
  fail "$receipt_path" "schema validation failed (schemas/bootstrap_receipt.schema.json)"
fi

if ! jq -e '
  (.policy_profile=="strict" or .policy_profile=="balanced" or .policy_profile=="creative") and
  (.governance_path=="service-local") and
  (.notes|type=="array" and length>0)
' "$policy_path" >/dev/null 2>&1; then
  fail "$policy_path" "invalid bootstrap policy profile contract"
fi

if ! jq -e '
  (.service_id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
  (.allowed_mcps|type=="array") and
  (all(.allowed_mcps[]?;
    (.mcp_id|type=="string" and test("^core-[a-z0-9][a-z0-9-]*$")) and
    (.capabilities|type=="array")
  ))
' "$allowlist_path" >/dev/null 2>&1; then
  fail "$allowlist_path" "invalid bootstrap mcp allowlist"
fi

if ! jq -e '
  .version=="v0.1" and
  .common_kpi_set=="governance-core-v1" and
  (.kpis|type=="array" and length>=7)
' "$slo_path" >/dev/null 2>&1; then
  fail "$slo_path" "invalid bootstrap slo contract"
fi

manifest_service_id="$(jq -r '.service_id' "$manifest_path")"
include_prompt_strategy="$(jq -r '.include_prompt_strategy' "$manifest_path")"
include_plan_strategy="$(jq -r '.include_plan_strategy' "$manifest_path")"
init_git_expected="$(jq -r '.init_git' "$manifest_path")"

for path in "$contract_path" "$allowlist_path" "$roles_path" "$handoffs_path"; do
  if ! jq -e --arg service_id "$manifest_service_id" '.service_id==$service_id' "$path" >/dev/null 2>&1; then
    fail "$path" "service_id does not match bootstrap manifest"
  fi
done

if [[ "$include_prompt_strategy" == "true" ]]; then
  check_json "$prompt_path"
  if ! jq -e '
    .version=="v0.1" and
    (.service_id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
    (.strategy_mode=="standard" or .strategy_mode=="ritual-uiux") and
    (.roles|type=="array" and length>0) and
    (.global_guardrails|type=="array" and length>0)
  ' "$prompt_path" >/dev/null 2>&1; then
    fail "$prompt_path" "schema validation failed (schemas/service_prompt_strategy.schema.json)"
  fi
else
  if [[ -f "$prompt_path" ]]; then
    fail "$prompt_path" "prompt strategy should be absent when disabled"
  fi
fi

if [[ "$include_plan_strategy" == "true" ]]; then
  check_json "$plan_path"
  if ! jq -e '
    .version=="v0.1" and
    (.service_id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
    (.strategy_mode=="standard" or .strategy_mode=="ritual-uiux") and
    (.phase_templates|type=="array" and length>0) and
    (.release_gate_defaults.owner_role_id|type=="string" and length>0)
  ' "$plan_path" >/dev/null 2>&1; then
    fail "$plan_path" "schema validation failed (schemas/service_plan_strategy.schema.json)"
  fi
else
  if [[ -f "$plan_path" ]]; then
    fail "$plan_path" "plan strategy should be absent when disabled"
  fi
fi

expected_manifest_hash="$(bash "$ROOT_DIR/scripts/hash_ref.sh" "$manifest_path")"
actual_manifest_hash="$(jq -r '.bootstrap_manifest_ref' "$receipt_path")"
if [[ "$expected_manifest_hash" != "$actual_manifest_hash" ]]; then
  fail "$receipt_path" "bootstrap_manifest_ref does not match manifest hash"
fi

while IFS=$'\t' read -r rel_path sha256 kind; do
  [[ -n "$rel_path" ]] || continue
  target_path="$output_dir/$rel_path"
  if [[ ! -f "$target_path" ]]; then
    fail "$receipt_path" "generated artifact '$rel_path' is missing"
    continue
  fi
  actual_hash="$(sha_file "$target_path")"
  if [[ "$actual_hash" != "$sha256" ]]; then
    fail "$receipt_path" "generated artifact hash mismatch for '$rel_path'"
  fi
done < <(jq -r '.generated_artifacts[] | [.path, .sha256, .kind] | @tsv' "$receipt_path")

if [[ "$init_git_expected" == "true" ]]; then
  if [[ ! -d "$output_dir/.git" ]]; then
    fail "$output_dir/.git" "git repository missing"
  fi
else
  if [[ -d "$output_dir/.git" ]]; then
    fail "$output_dir/.git" "git repository should be absent"
  fi
fi

if (( errors > 0 )); then
  echo "BOOTSTRAP_VALIDATION_FAIL count=$errors" >&2
  exit 1
fi

echo "BOOTSTRAP_VALIDATION_PASS output=$output_dir"
