#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
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
  echo "VALIDATION_ERROR ${rel_path}: ${message}" >&2
  errors=$((errors + 1))
}

check_file() {
  local rel_path="$1"
  if [[ ! -f "$ROOT_DIR/$rel_path" ]]; then
    fail "$rel_path" "missing file"
    return 1
  fi
  return 0
}

check_dir() {
  local rel_path="$1"
  if [[ ! -d "$ROOT_DIR/$rel_path" ]]; then
    fail "$rel_path" "missing directory"
    return 1
  fi
  return 0
}

is_expected_name() {
  local candidate="$1"
  shift
  local expected
  for expected in "$@"; do
    if [[ "$candidate" == "$expected" ]]; then
      return 0
    fi
  done
  return 1
}

check_exact_files_in_dir() {
  local rel_dir="$1"
  shift
  local expected_files=("$@")
  local expected_file
  local existing_path
  local existing_name

  if ! check_dir "$rel_dir"; then
    return
  fi

  for expected_file in "${expected_files[@]}"; do
    check_file "$rel_dir/$expected_file"
  done

  while IFS= read -r existing_path; do
    existing_name="$(basename "$existing_path")"
    if ! is_expected_name "$existing_name" "${expected_files[@]}"; then
      fail "$rel_dir/$existing_name" "extra file not allowed in fixed set"
    fi
  done < <(find "$ROOT_DIR/$rel_dir" -mindepth 1 -maxdepth 1 -type f | sort)

  while IFS= read -r existing_path; do
    existing_name="$(basename "$existing_path")"
    fail "$rel_dir/$existing_name" "extra directory not allowed in fixed set"
  done < <(find "$ROOT_DIR/$rel_dir" -mindepth 1 -maxdepth 1 -type d | sort)
}

check_allowed_entries_in_dir() {
  local rel_dir="$1"
  shift
  local allowed_entries=("$@")
  local existing_path
  local existing_name

  if ! check_dir "$rel_dir"; then
    return
  fi

  while IFS= read -r existing_path; do
    existing_name="$(basename "$existing_path")"
    if ! is_expected_name "$existing_name" "${allowed_entries[@]}"; then
      fail "$rel_dir/$existing_name" "entry not allowed by fixed structure"
    fi
  done < <(find "$ROOT_DIR/$rel_dir" -mindepth 1 -maxdepth 1 | sort)
}

check_services_have_agents() {
  local services_root="services"
  local service_path
  local service_name

  if ! check_dir "$services_root"; then
    return
  fi

  while IFS= read -r service_path; do
    service_name="$(basename "$service_path")"
    if [[ ! -f "$service_path/AGENTS.md" ]]; then
      fail "$services_root/$service_name/AGENTS.md" "missing service-level AGENTS.md"
    fi
  done < <(find "$ROOT_DIR/$services_root" -mindepth 1 -maxdepth 1 -type d | sort)
}

check_json() {
  local rel_path="$1"
  if ! check_file "$rel_path"; then
    return 1
  fi
  if ! jq -e . "$ROOT_DIR/$rel_path" >/dev/null 2>&1; then
    fail "$rel_path" "invalid JSON"
    return 1
  fi
  return 0
}

json_ready() {
  local rel_path="$1"
  [[ -f "$ROOT_DIR/$rel_path" ]] && jq -e . "$ROOT_DIR/$rel_path" >/dev/null 2>&1
}

validate_jq_contract() {
  local rel_path="$1"
  local schema_rel="$2"
  local jq_expr="$3"

  if ! check_json "$rel_path"; then
    return
  fi
  if ! check_json "$schema_rel"; then
    return
  fi

  if ! jq -e "$jq_expr" "$ROOT_DIR/$rel_path" >/dev/null 2>&1; then
    fail "$rel_path" "schema validation failed (${schema_rel})"
  fi
}

require jq

ORG_REG_REL="control/registry/org.v0.1.json"
SERVICES_REG_REL="control/registry/services.v0.1.json"
MCPS_REG_REL="control/registry/mcps.v0.1.json"

SERVICE_DOCS_FIXED=(
  "SERVICE.md"
  "SLO.md"
  "RISK.md"
  "RUNBOOK.md"
  "DATA.md"
  "INTEGRATIONS.md"
  "CHANGELOG.md"
)

MCP_DOCS_FIXED=(
  "MCP.md"
  "CAPABILITIES.md"
  "SECURITY.md"
)

# Ensure all schema contracts exist and are valid JSON.
for schema_rel in \
  schemas/envelope.schema.json \
  schemas/acceptance.schema.json \
  schemas/evidence.schema.json \
  schemas/benchmark_kpi.schema.json \
  schemas/bridge_intent.schema.json \
  schemas/org.schema.json \
  schemas/services_registry.schema.json \
  schemas/mcps_registry.schema.json \
  schemas/mcp_allowlist.schema.json \
  schemas/mcp_manifest.schema.json
  do
  check_json "$schema_rel"
done

# Control room fixed document sets (freeze line).
check_exact_files_in_dir "control/registry" \
  "org.v0.1.json" \
  "services.v0.1.json" \
  "mcps.v0.1.json"

check_exact_files_in_dir "control/playbooks" \
  "incident.md" \
  "change-management.md" \
  "onboarding.md"

check_exact_files_in_dir "control/templates/service" "${SERVICE_DOCS_FIXED[@]}"
check_exact_files_in_dir "control/templates/mcp" "${MCP_DOCS_FIXED[@]}"

# Existing governance core validation contracts.
validate_jq_contract "fixtures/intent.envelope.json" "schemas/envelope.schema.json" '
  (.intent_id | type=="string" and length>0) and
  (.policy_profile=="strict" or .policy_profile=="balanced" or .policy_profile=="creative") and
  (.state_ref | test("^[a-f0-9]{64}$")) and
  (.plan_ref==null or (.plan_ref | test("^[a-f0-9]{64}$"))) and
  (.budget.max_tokens | type=="number" and .>0) and
  (.budget.max_steps | type=="number" and .>0) and
  (.acceptance_tests_ref==null or (.acceptance_tests_ref | test("^[a-f0-9]{64}$")))
'

validate_jq_contract "fixtures/acceptance.tests.json" "schemas/acceptance.schema.json" '
  (.must_include_sources | type=="boolean") and
  (.max_hallucination_score | type=="number" and .>=0 and .<=1) and
  (.required_sections | type=="array" and length>0)
'

validate_jq_contract "fixtures/bridge/pm_intent.sample.json" "schemas/bridge_intent.schema.json" '
  (.intent_id|type=="string" and test("^[a-zA-Z0-9][a-zA-Z0-9._-]*$")) and
  (.objective|type=="string" and length>0) and
  (.constraints|type=="array" and length>0 and all(.[]; type=="string" and length>0)) and
  (.approval_tier=="low" or .approval_tier=="medium" or .approval_tier=="high") and
  (.human_gate_required|type=="boolean") and
  (.target_executor=="codex" or .target_executor=="other-agent") and
  (.evidence_refs|type=="array") and
  (all(.evidence_refs[]?;
    (.path|type=="string" and length>0) and
    (.sha256|type=="string" and test("^[a-f0-9]{64}$"))
  ))
'

validate_jq_contract "fixtures/evidence.summary.json" "schemas/evidence.schema.json" '
  (.source=="jira" or .source=="github" or .source=="web" or .source=="db") and
  (.content_ref|test("^[a-f0-9]{64}$")) and
  (.confidence|type=="number" and .>=0 and .<=1) and
  (.access_level=="internal" or .access_level=="public") and
  (.sections|type=="array") and
  (.hallucination_score|type=="number" and .>=0 and .<=1)
'

validate_jq_contract "policies/approval_tier_policy.v0.1.json" "schemas/trace_record.schema.json" '
  .version=="v0.1" and
  (.tiers.low.approval_mode=="auto") and
  (.tiers.medium.approval_mode=="policy_plus_owner") and
  (.tiers.high.approval_mode=="mandatory_human_gate")
'

validate_jq_contract "benchmark/efficiency_benchmark_spec.v0.1.json" "schemas/benchmark_kpi.schema.json" '
  .version=="v0.1" and
  (.kpi_thresholds.min_acceptance_pass_rate>=0 and .kpi_thresholds.min_acceptance_pass_rate<=1) and
  (.kpi_thresholds.min_cache_hit_rate>=0 and .kpi_thresholds.min_cache_hit_rate<=1) and
  (.kpi_thresholds.max_fallback_rate>=0 and .kpi_thresholds.max_fallback_rate<=1) and
  (.kpi_thresholds.min_cost_reduction_vs_baseline>=0)
'

# Central control room registry validation contracts.
validate_jq_contract "$ORG_REG_REL" "schemas/org.schema.json" '
  .version=="v0.1" and
  (.company_departments | type=="array" and length>0) and
  (all(.company_departments[];
    (.name|type=="string" and length>0) and
    (.owner|type=="string" and length>0) and
    (.portfolio_services|type=="array") and
    (all(.portfolio_services[]?; type=="string" and length>0))
  )) and
  ([.company_departments[].name] | length==(unique|length)) and
  (.government_ministries | type=="array" and length>0) and
  (all(.government_ministries[];
    (.name|type=="string" and length>0) and
    (.mandate|type=="string" and length>0) and
    (.policy_scopes|type=="array" and length>0) and
    (all(.policy_scopes[]?; type=="string" and length>0))
  )) and
  ([.government_ministries[].name] | length==(unique|length)) and
  (.mappings | type=="array" and length>0) and
  (all(.mappings[];
    (.company_department|type=="string" and length>0) and
    (.government_ministry|type=="string" and length>0) and
    (.notes|type=="string")
  )) and
  (([.company_departments[].name]) as $depts |
   ([.government_ministries[].name]) as $ministries |
   all(.mappings[];
     .company_department as $dept_name |
     .government_ministry as $ministry_name |
     ($depts | index($dept_name)) != null and
     ($ministries | index($ministry_name)) != null
   ))
'

validate_jq_contract "$SERVICES_REG_REL" "schemas/services_registry.schema.json" '
  .version=="v0.1" and
  (.services | type=="array" and length>0) and
  (all(.services[];
    (.id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
    (.name|type=="string" and length>0) and
    (.owner|type=="string" and length>0) and
    (.dept|type=="string" and length>0) and
    (.ministry|type=="string" and length>0) and
    (.repo_path|type=="string" and length>0) and
    (.policy_profile_ref|type=="string" and length>0) and
    (.mcp_allowlist_path|type=="string" and length>0) and
    (.docs_path|type=="string" and length>0)
  )) and
  ([.services[].id] | length==(unique|length)) and
  ([.services[].repo_path] | length==(unique|length))
'

validate_jq_contract "$MCPS_REG_REL" "schemas/mcps_registry.schema.json" '
  .version=="v0.1" and
  (.mcps | type=="array" and length>0) and
  (all(.mcps[];
    (.id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
    (.name|type=="string" and length>0) and
    (.root_path|type=="string" and test("^mcps/[a-z0-9][a-z0-9-]*$")) and
    (.version|type=="string" and test("^[0-9]+\\.[0-9]+\\.[0-9]+$")) and
    (.capabilities|type=="array" and length>0 and length==(unique|length) and all(.[]; type=="string" and length>0)) and
    (.risk_level=="low" or .risk_level=="medium" or .risk_level=="high") and
    (.required_approval_tier=="low" or .required_approval_tier=="medium" or .required_approval_tier=="high") and
    (.pinned_ref_hash|type=="string" and test("^sha256:[a-f0-9]{64}$"))
  )) and
  ([.mcps[].id] | length==(unique|length)) and
  ([.mcps[].root_path] | length==(unique|length))
'

# Ensure every service has a service-level AGENTS policy narrowing file.
check_services_have_agents

if [[ -d "$ROOT_DIR/packages/mcps" ]]; then
  fail "packages/mcps" "unsupported MCP root; use mcps/<mcp-name>"
fi

# Cross-registry consistency checks.
if json_ready "$ORG_REG_REL" && json_ready "$SERVICES_REG_REL"; then
  if ! jq -ne \
    --slurpfile org "$ROOT_DIR/$ORG_REG_REL" \
    --slurpfile services "$ROOT_DIR/$SERVICES_REG_REL" '
      ($org[0].company_departments | map(.name)) as $dept_names |
      ($org[0].government_ministries | map(.name)) as $ministry_names |
      ($services[0].services | map(.id)) as $service_ids |
      (all($services[0].services[];
        .dept as $dept_name |
        .ministry as $ministry_name |
        ($dept_names | index($dept_name)) != null and
        ($ministry_names | index($ministry_name)) != null
      )) and
      (all($org[0].company_departments[]?.portfolio_services[]?;
        . as $portfolio_service |
        ($service_ids | index($portfolio_service)) != null
      ))
    ' >/dev/null 2>&1; then
    fail "$SERVICES_REG_REL" "department/ministry/portfolio references are inconsistent with ${ORG_REG_REL}"
  fi
fi

# Validate each service contract package.
if json_ready "$SERVICES_REG_REL"; then
  while IFS=$'\t' read -r service_id repo_path policy_profile_ref mcp_allowlist_path docs_path; do
    [[ -n "$service_id" ]] || continue

    check_dir "$repo_path"
    check_file "$policy_profile_ref"
    check_file "$mcp_allowlist_path"
    check_dir "$docs_path"

    check_exact_files_in_dir "$docs_path" "${SERVICE_DOCS_FIXED[@]}"

    if check_json "$policy_profile_ref"; then
      if ! jq -e '
        (.policy_profile_file|type=="string" and length>0) and
        (.policy_profile|type=="string" and length>0)
      ' "$ROOT_DIR/$policy_profile_ref" >/dev/null 2>&1; then
        fail "$policy_profile_ref" "invalid policy profile contract"
      else
        policy_profile_file="$(jq -r '.policy_profile_file' "$ROOT_DIR/$policy_profile_ref")"
        policy_profile_name="$(jq -r '.policy_profile' "$ROOT_DIR/$policy_profile_ref")"

        check_file "$policy_profile_file"
        if json_ready "$policy_profile_file"; then
          if ! jq -e --arg p "$policy_profile_name" 'has($p)' "$ROOT_DIR/$policy_profile_file" >/dev/null 2>&1; then
            fail "$policy_profile_ref" "policy profile '$policy_profile_name' not found in ${policy_profile_file}"
          fi
        fi
      fi
    fi

    if check_json "$mcp_allowlist_path"; then
      if ! jq -e '
        (.service_id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
        (.allowed_mcps|type=="array") and
        (all(.allowed_mcps[]?;
          (.mcp_id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
          (.capabilities|type=="array" and length>0 and length==(unique|length) and all(.[]; type=="string" and length>0))
        ))
      ' "$ROOT_DIR/$mcp_allowlist_path" >/dev/null 2>&1; then
        fail "$mcp_allowlist_path" "schema validation failed (schemas/mcp_allowlist.schema.json)"
      fi

      allowlist_service_id="$(jq -r '.service_id // ""' "$ROOT_DIR/$mcp_allowlist_path")"
      if [[ "$allowlist_service_id" != "$service_id" ]]; then
        fail "$mcp_allowlist_path" "service_id '$allowlist_service_id' does not match registry service id '$service_id'"
      fi

      if json_ready "$MCPS_REG_REL"; then
        while IFS= read -r allowed_mcp_id; do
          [[ -n "$allowed_mcp_id" ]] || continue
          if ! jq -e --arg mcp_id "$allowed_mcp_id" '.mcps | any(.id==$mcp_id)' "$ROOT_DIR/$MCPS_REG_REL" >/dev/null 2>&1; then
            fail "$mcp_allowlist_path" "unknown MCP id '$allowed_mcp_id' (not found in ${MCPS_REG_REL})"
          fi
        done < <(jq -r '.allowed_mcps[]?.mcp_id' "$ROOT_DIR/$mcp_allowlist_path")

        while IFS=$'\t' read -r allowed_mcp_id capability; do
          [[ -n "$allowed_mcp_id" && -n "$capability" ]] || continue
          if ! jq -e --arg mcp_id "$allowed_mcp_id" --arg capability "$capability" '
              .mcps | any(.id==$mcp_id and (.capabilities | index($capability) != null))
            ' "$ROOT_DIR/$MCPS_REG_REL" >/dev/null 2>&1; then
            fail "$mcp_allowlist_path" "capability '$capability' is not allowed for MCP '$allowed_mcp_id' in ${MCPS_REG_REL}"
          fi
        done < <(jq -r '.allowed_mcps[]? | .mcp_id as $mcp_id | .capabilities[]? | [$mcp_id, .] | @tsv' "$ROOT_DIR/$mcp_allowlist_path")
      fi
    fi
  done < <(jq -r '.services[] | [.id, .repo_path, .policy_profile_ref, .mcp_allowlist_path, .docs_path] | @tsv' "$ROOT_DIR/$SERVICES_REG_REL")
fi

# Every services/* directory must be in central services registry.
if json_ready "$SERVICES_REG_REL" && [[ -d "$ROOT_DIR/services" ]]; then
  while IFS= read -r service_dir; do
    service_name="$(basename "$service_dir")"
    if ! jq -e --arg repo_path "services/${service_name}" '.services | any(.repo_path==$repo_path)' "$ROOT_DIR/$SERVICES_REG_REL" >/dev/null 2>&1; then
      fail "services/${service_name}" "service directory not registered in ${SERVICES_REG_REL}"
    fi
  done < <(find "$ROOT_DIR/services" -mindepth 1 -maxdepth 1 -type d | sort)
fi

# Validate each MCP package contract.
if json_ready "$MCPS_REG_REL"; then
  while IFS=$'\t' read -r mcp_id root_path mcp_version required_tier; do
    [[ -n "$mcp_id" ]] || continue

    manifest_rel="$root_path/manifest.json"
    check_dir "$root_path"
    check_file "$manifest_rel"
    check_allowed_entries_in_dir "$root_path" "manifest.json" "docs" "versions"
    check_exact_files_in_dir "$root_path/docs" "${MCP_DOCS_FIXED[@]}"

    if check_json "$manifest_rel"; then
      if ! jq -e '
        (.id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
        (.version|type=="string" and test("^[0-9]+\\.[0-9]+\\.[0-9]+$")) and
        (.capabilities|type=="array" and length>0 and length==(unique|length) and all(.[]; type=="string" and length>0)) and
        (.required_approval_tier=="low" or .required_approval_tier=="medium" or .required_approval_tier=="high")
      ' "$ROOT_DIR/$manifest_rel" >/dev/null 2>&1; then
        fail "$manifest_rel" "schema validation failed (schemas/mcp_manifest.schema.json)"
      fi

      if ! jq -e --arg id "$mcp_id" '.id==$id' "$ROOT_DIR/$manifest_rel" >/dev/null 2>&1; then
        fail "$manifest_rel" "manifest id does not match registry id '$mcp_id'"
      fi
      if ! jq -e --arg version "$mcp_version" '.version==$version' "$ROOT_DIR/$manifest_rel" >/dev/null 2>&1; then
        fail "$manifest_rel" "manifest version does not match registry version '$mcp_version'"
      fi
      if ! jq -e --arg tier "$required_tier" '.required_approval_tier==$tier' "$ROOT_DIR/$manifest_rel" >/dev/null 2>&1; then
        fail "$manifest_rel" "manifest required_approval_tier does not match registry tier '$required_tier'"
      fi
      if ! jq -e --arg mcp_id "$mcp_id" --slurpfile registry "$ROOT_DIR/$MCPS_REG_REL" '
          (.capabilities | sort) == (($registry[0].mcps[] | select(.id==$mcp_id) | .capabilities | sort))
        ' "$ROOT_DIR/$manifest_rel" >/dev/null 2>&1; then
        fail "$manifest_rel" "manifest capabilities do not match ${MCPS_REG_REL} for MCP '$mcp_id'"
      fi
    fi
  done < <(jq -r '.mcps[] | [.id, .root_path, .version, .required_approval_tier] | @tsv' "$ROOT_DIR/$MCPS_REG_REL")
fi

# Every mcps/* directory must be in central MCP registry.
if json_ready "$MCPS_REG_REL" && [[ -d "$ROOT_DIR/mcps" ]]; then
  while IFS= read -r mcp_dir; do
    mcp_name="$(basename "$mcp_dir")"
    if ! jq -e --arg root_path "mcps/${mcp_name}" '.mcps | any(.root_path==$root_path)' "$ROOT_DIR/$MCPS_REG_REL" >/dev/null 2>&1; then
      fail "mcps/${mcp_name}" "MCP directory not registered in ${MCPS_REG_REL}"
    fi
  done < <(find "$ROOT_DIR/mcps" -mindepth 1 -maxdepth 1 -type d | sort)
fi

if (( errors > 0 )); then
  echo "VALIDATION_FAIL count=${errors}" >&2
  exit 1
fi

echo "VALIDATION_PASS"
