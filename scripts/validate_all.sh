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

sha256_file() {
  local target="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$target" | awk '{print $1}'
  else
    shasum -a 256 "$target" | awk '{print $1}'
  fi
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

bash "$ROOT_DIR/scripts/scan_repo_hygiene.sh"

ORG_REG_REL="control/registry/org.v0.1.json"
SERVICES_REG_REL="control/registry/services.v0.1.json"
MCPS_REG_REL="control/registry/mcps.v0.1.json"

SERVICE_PACKAGE_FIXED=(
  "contract.bundle.v0.1.json"
  "mcp.allowlist.json"
  "policy.profile.json"
  "slo.contract.v0.1.json"
)

# Ensure all schema contracts exist and are valid JSON.
for schema_rel in \
  schemas/envelope.schema.json \
  schemas/acceptance.schema.json \
  schemas/evidence.schema.json \
  schemas/benchmark_kpi.schema.json \
  schemas/bridge_intent.schema.json \
  schemas/agent_routing_policy.schema.json \
  schemas/org.schema.json \
  schemas/services_registry.schema.json \
  schemas/service_contract_bundle.schema.json \
  schemas/service_slo_contract.schema.json \
  schemas/mcps_registry.schema.json \
  schemas/mcp_allowlist.schema.json \
  schemas/mcp_manifest.schema.json \
  schemas/mcp_contract_bundle.schema.json \
  schemas/mcp_runtime_binding.schema.json \
  schemas/mcp_change_request.schema.json \
  schemas/control_playbook.schema.json \
  schemas/trace_rules.schema.json \
  schemas/mcp_ownership_policy.schema.json \
  schemas/cloud_batch_jobs_manifest.schema.json \
  schemas/cloud_batch_results_manifest.schema.json \
  schemas/cloud_batch_verify_verdict.schema.json
  do
  check_json "$schema_rel"
done

# Control room fixed document sets (freeze line).
check_exact_files_in_dir "control/registry" \
  "org.v0.1.json" \
  "services.v0.1.json" \
  "mcps.v0.1.json"

check_exact_files_in_dir "control/playbooks" \
  "incident.v0.1.json" \
  "change-management.v0.1.json" \
  "onboarding.v0.1.json"

check_exact_files_in_dir "control/benchmarks" \
  "efficiency_benchmark_spec.v0.1.json"

check_exact_files_in_dir "control/agents" \
  "departments.v0.1.json"

check_exact_files_in_dir "control/prompts" \
  "library.v0.1.json"

check_exact_files_in_dir "control/specs" \
  "opcodes.v0.1.json" \
  "trace_rules.v0.1.json"

check_exact_files_in_dir "control/templates/service" "contract.bundle.template.v0.1.json"
check_exact_files_in_dir "control/templates/mcp" "contract.bundle.template.v0.1.json"

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
  (.target_executor|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
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

validate_jq_contract "policies/cloud_batch_policy.v0.1.json" "schemas/trace_record.schema.json" '
  .version=="v0.1" and
  (.thresholds.token_total|type=="number" and .>0) and
  (.thresholds.max_latency_ms|type=="number" and .>0) and
  (.thresholds.fail_rate|type=="number" and .>=0 and .<=1) and
  (.mode_defaults.strictness=="hybrid" or .mode_defaults.strictness=="strict" or .mode_defaults.strictness=="soft")
'

validate_jq_contract "policies/agent_routing_policy.v0.1.json" "schemas/agent_routing_policy.schema.json" '
  .version=="v0.1" and
  (.allowed_executors_by_tier|type=="object") and
  (.allowed_executors_by_tier.low|type=="array" and length>0 and length==(unique|length) and all(.[]; type=="string" and test("^[a-z0-9][a-z0-9-]*$"))) and
  (.allowed_executors_by_tier.medium|type=="array" and length>0 and length==(unique|length) and all(.[]; type=="string" and test("^[a-z0-9][a-z0-9-]*$"))) and
  (.allowed_executors_by_tier.high|type=="array" and length>0 and length==(unique|length) and all(.[]; type=="string" and test("^[a-z0-9][a-z0-9-]*$"))) and
  (.fallback_chain|type=="array" and length>0 and length==(unique|length) and all(.[]; type=="string" and test("^[a-z0-9][a-z0-9-]*$"))) and
  (.fallback_chain | index("governance-council") != null)
'

validate_jq_contract "control/agents/departments.v0.1.json" "schemas/trace_record.schema.json" '
  .version=="v0.1" and
  (.departments|type=="array" and length>0) and
  (all(.departments[];
    (.id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
    (.name|type=="string" and length>0) and
    (.purpose|type=="string" and length>0) and
    (.default_prompt_set|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
    (.supports_roles|type=="array" and length>0 and all(.[]; .=="architect-owner"))
  )) and
  ([.departments[].id] | length==(unique|length))
'

validate_jq_contract "control/prompts/library.v0.1.json" "schemas/trace_record.schema.json" '
  .version=="v0.1" and
  (.prompt_sets|type=="array" and length>0) and
  (all(.prompt_sets[];
    (.id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
    (.purpose|type=="string" and length>0)
  )) and
  ([.prompt_sets[].id] | length==(unique|length))
'

if json_ready "control/agents/departments.v0.1.json" && json_ready "control/prompts/library.v0.1.json"; then
  while IFS=$'\t' read -r dept_id prompt_set; do
    [[ -n "$dept_id" ]] || continue
    if ! jq -e --arg id "$prompt_set" '.prompt_sets | any(.id==$id)' "$ROOT_DIR/control/prompts/library.v0.1.json" >/dev/null 2>&1; then
      fail "control/agents/departments.v0.1.json" "department '$dept_id' default_prompt_set '$prompt_set' not found in control/prompts/library.v0.1.json"
    fi
  done < <(jq -r '.departments[] | [.id, .default_prompt_set] | @tsv' "$ROOT_DIR/control/agents/departments.v0.1.json")
fi

if json_ready "control/agents/departments.v0.1.json" && json_ready "policies/agent_routing_policy.v0.1.json"; then
  while IFS= read -r lane; do
    [[ -n "$lane" ]] || continue
    if ! jq -e --arg id "$lane" '.departments | any(.id==$id)' "$ROOT_DIR/control/agents/departments.v0.1.json" >/dev/null 2>&1; then
      fail "policies/agent_routing_policy.v0.1.json" "routing lane '$lane' not found in control/agents/departments.v0.1.json"
    fi
  done < <(jq -r '
    (.allowed_executors_by_tier.low[]?),
    (.allowed_executors_by_tier.medium[]?),
    (.allowed_executors_by_tier.high[]?),
    (.fallback_chain[]?)
  ' "$ROOT_DIR/policies/agent_routing_policy.v0.1.json" | sort -u)
fi

validate_jq_contract "control/benchmarks/efficiency_benchmark_spec.v0.1.json" "schemas/benchmark_kpi.schema.json" '
  .version=="v0.1" and
  (.kpi_thresholds.min_acceptance_pass_rate>=0 and .kpi_thresholds.min_acceptance_pass_rate<=1) and
  (.kpi_thresholds.min_cache_hit_rate>=0 and .kpi_thresholds.min_cache_hit_rate<=1) and
  (.kpi_thresholds.max_fallback_rate>=0 and .kpi_thresholds.max_fallback_rate<=1) and
  (.kpi_thresholds.min_cost_reduction_vs_baseline>=0)
'

validate_jq_contract "control/playbooks/incident.v0.1.json" "schemas/control_playbook.schema.json" '
  .version=="v0.1" and
  (.playbook_id=="incident") and
  (.trigger_conditions|type=="array" and length>0) and
  (.execution_steps|type=="array" and length>0) and
  (.rollback_condition|type=="array" and length>0)
'

validate_jq_contract "control/playbooks/change-management.v0.1.json" "schemas/control_playbook.schema.json" '
  .version=="v0.1" and
  (.playbook_id=="change-management") and
  (.required_inputs|type=="array" and length>0) and
  (.execution_steps|type=="array" and length>0) and
  (.evidence_outputs|type=="array" and length>0)
'

validate_jq_contract "control/playbooks/onboarding.v0.1.json" "schemas/control_playbook.schema.json" '
  .version=="v0.1" and
  (.playbook_id=="onboarding") and
  (.required_inputs|type=="array" and length>0) and
  (.execution_steps|type=="array" and length>0) and
  (.rollback_condition|type=="array" and length>0)
'

validate_jq_contract "control/specs/trace_rules.v0.1.json" "schemas/trace_rules.schema.json" '
  .version=="v0.1" and
  (.append_only==true) and
  (.hash_reference_required==true) and
  (.allowed_record_types|type=="array" and length>0) and
  (.forbidden_mutations|type=="array" and length>0) and
  (.retention_model.primary_store=="traces/") and
  (.journal_export_boundary.mcp_id=="core-governance-journal-mcp") and
  (.journal_export_boundary.target_service=="obsidian-mcp")
'

validate_jq_contract "policies/mcp_ownership_policy.v0.1.json" "schemas/mcp_ownership_policy.schema.json" '
  .version=="v0.1" and
  (.central_ownership|type=="array" and length>0) and
  (.service_ownership|type=="array" and length>0) and
  (.non_negotiable_rules|type=="array" and length>0) and
  (.service_scoped_exception.allowed|type=="boolean") and
  (.service_scoped_exception.conditions|type=="array" and length>0)
'

validate_jq_contract "control/templates/service/contract.bundle.template.v0.1.json" "schemas/service_contract_bundle.schema.json" '
  .version=="v0.1" and
  (.service_id=="example-service") and
  (.owner_role=="architect-owner") and
  (.governance_scope.execution_path=="mandatory_bridge")
'

validate_jq_contract "control/templates/mcp/contract.bundle.template.v0.1.json" "schemas/mcp_contract_bundle.schema.json" '
  .version=="v0.1" and
  (.mcp_id=="core-example-mcp") and
  (.capability_contract.required_approval_tier=="medium") and
  (.runtime_contract.binding_ref=="control/mcps/core-example-mcp/versions/runtime.binding.v0.1.json")
'

validate_jq_contract "fixtures/cloud_batch/jobs.sample.v0.1.json" "schemas/cloud_batch_jobs_manifest.schema.json" '
  .version=="v0.1" and
  (.service_id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
  (.run_id|type=="string" and test("^[a-zA-Z0-9][a-zA-Z0-9._-]*$")) and
  (.jobs|type=="array" and length>0) and
  (all(.jobs[];
    (.job_id|type=="string" and test("^[a-zA-Z0-9][a-zA-Z0-9._-]*$")) and
    (.objective_ref|type=="string" and length>0) and
    (.input_artifacts|type=="array") and
    (all(.input_artifacts[]?;
      (.path|type=="string" and length>0) and
      (.sha256|type=="string" and test("^[a-f0-9]{64}$")) and
      (.role|type=="string" and length>0)
    )) and
    (.expected_outputs|type=="array" and length>0) and
    (all(.expected_outputs[];
      (.role|type=="string" and length>0) and
      ((.required // true)|type=="boolean")
    ))
  ))
'

validate_jq_contract "fixtures/cloud_batch/results.sample.v0.1.json" "schemas/cloud_batch_results_manifest.schema.json" '
  .version=="v0.1" and
  (.service_id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
  (.run_id|type=="string" and test("^[a-zA-Z0-9][a-zA-Z0-9._-]*$")) and
  (.results|type=="array" and length>0) and
  (all(.results[];
    (.job_id|type=="string" and test("^[a-zA-Z0-9][a-zA-Z0-9._-]*$")) and
    (.status=="success" or .status=="failed" or .status=="timeout" or .status=="canceled") and
    (.artifacts|type=="array") and
    (all(.artifacts[]?;
      (.path|type=="string" and length>0) and
      (.sha256|type=="string" and test("^[a-f0-9]{64}$")) and
      (.role|type=="string" and length>0)
    )) and
    (.usage.tokens_in|type=="number" and .>=0) and
    (.usage.tokens_out|type=="number" and .>=0) and
    (.usage.latency_ms|type=="number" and .>=0)
  ))
'

# Validate MCP change request artifacts.
if [[ -d "$ROOT_DIR/traces/governance" ]]; then
  while IFS= read -r request_path; do
    request_rel="${request_path#$ROOT_DIR/}"
    validate_jq_contract "$request_rel" "schemas/mcp_change_request.schema.json" '
      .version=="v0.1" and
      (.request_id|type=="string" and length>0) and
      (.service_id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
      (.requested_at|type=="string" and length>0) and
      (.risk_tier==null or .risk_tier=="low" or .risk_tier=="medium" or .risk_tier=="high") and
      (.status=="proposed" or .status=="requested" or .status=="approved" or .status=="rejected" or .status=="implemented" or .status=="deferred") and
      (
        (
          ((.request_type // "capability_expansion") != "new_mcp_registration") and
          (.approval_tier=="low" or .approval_tier=="medium" or .approval_tier=="high") and
          (.human_gate_required|type=="boolean") and
          (.title|type=="string" and length>0) and
          (.objective|type=="string" and length>0) and
          (.required_capabilities|type=="array" and length>0 and all(.[]; type=="string" and length>0)) and
          (.constraints|type=="array" and length>0 and all(.[]; type=="string" and length>0)) and
          (.evidence_refs|type=="array" and length>0 and all(.[]; (.path|type=="string" and length>0) and (.sha256|type=="string" and test("^[a-f0-9]{64}$")))) and
          (.target_core_mcp_id==null or (.target_core_mcp_id|type=="string" and test("^core-[a-z0-9][a-z0-9-]*$")))
        )
        or
        (
          .request_type=="new_mcp_registration" and
          .approval_tier=="high" and
          .human_gate_required==true and
          (.mcp_candidate.id|type=="string" and test("^core-[a-z0-9][a-z0-9-]*$")) and
          (.mcp_candidate.proposed_root_path|type=="string" and test("^control/mcps/core-[a-z0-9][a-z0-9-]*$")) and
          (.mcp_candidate.capabilities|type=="array" and length>0 and all(.[]; type=="string" and length>0)) and
          (.mcp_candidate.required_approval_tier=="high") and
          (.mcp_candidate.risk_level=="high") and
          (.governance_rationale.need|type=="string" and length>0) and
          (.governance_rationale.boundary|type=="string" and length>0) and
          (.governance_rationale.controls|type=="array" and length>0 and all(.[]; type=="string" and length>0)) and
          (.expected_artifacts|type=="array" and length>0 and all(.[]; type=="string" and length>0))
        )
      )
    '

    if check_json "$request_rel"; then
      while IFS=$'\t' read -r evidence_path expected_hash; do
        [[ -n "$evidence_path" && -n "$expected_hash" ]] || continue

        if [[ "$evidence_path" == /* ]]; then
          fail "$request_rel" "evidence_refs.path must be repository-relative ('${evidence_path}')"
          continue
        fi

        if [[ ! -f "$ROOT_DIR/$evidence_path" ]]; then
          fail "$request_rel" "evidence_refs.path missing file ('${evidence_path}')"
          continue
        fi

        actual_hash="$(sha256_file "$ROOT_DIR/$evidence_path")"
        if [[ "$actual_hash" != "$expected_hash" ]]; then
          fail "$request_rel" "evidence_refs.sha256 mismatch for '${evidence_path}' (expected ${expected_hash}, actual ${actual_hash})"
        fi
      done < <(jq -r '.evidence_refs[]? | [.path, .sha256] | @tsv' "$ROOT_DIR/$request_rel")
    fi
  done < <(find "$ROOT_DIR/traces/governance" -maxdepth 1 -type f -name 'mcp-request-*.json' | sort)
fi

if [[ -d "$ROOT_DIR/traces/governance/batch" ]]; then
  while IFS= read -r verdict_path; do
    verdict_rel="${verdict_path#$ROOT_DIR/}"
    validate_jq_contract "$verdict_rel" "schemas/cloud_batch_verify_verdict.schema.json" '
      .version=="v0.1" and
      (.service_id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
      (.run_id|type=="string" and test("^[a-zA-Z0-9][a-zA-Z0-9._-]*$")) and
      (.strictness=="hybrid" or .strictness=="strict" or .strictness=="soft") and
      (.verification_status=="pass" or .verification_status=="fail") and
      (.metrics.total_jobs|type=="number" and .>=0) and
      (.metrics.success_jobs|type=="number" and .>=0) and
      (.metrics.failed_jobs|type=="number" and .>=0) and
      (.metrics.tokens_in_total|type=="number" and .>=0) and
      (.metrics.tokens_out_total|type=="number" and .>=0) and
      (.metrics.max_latency_ms|type=="number" and .>=0) and
      (.metrics.fail_rate|type=="number" and .>=0 and .<=1) and
      (.metrics.artifact_checks|type=="number" and .>=0) and
      (.fail_reasons|type=="array") and
      (.warnings|type=="array")
    '
  done < <(find "$ROOT_DIR/traces/governance/batch" -type f -name 'verify.verdict.json' | sort)
fi

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
    (.contract_bundle_ref|type=="string" and length>0) and
    (has("docs_path") | not) and
    (.slo_contract_ref|type=="string" and length>0)
  )) and
  ([.services[].id] | length==(unique|length)) and
  ([.services[].repo_path] | length==(unique|length)) and
  ([.services[].contract_bundle_ref] | length==(unique|length))
'

validate_jq_contract "$MCPS_REG_REL" "schemas/mcps_registry.schema.json" '
  .version=="v0.1" and
  (.mcps | type=="array" and length>0) and
  (all(.mcps[];
    (.id|type=="string" and test("^core-[a-z0-9][a-z0-9-]*$")) and
    (.name|type=="string" and length>0) and
    (.root_path|type=="string" and test("^control/mcps/core-[a-z0-9][a-z0-9-]*$")) and
    (.version|type=="string" and test("^[0-9]+\\.[0-9]+\\.[0-9]+$")) and
    (.capabilities|type=="array" and length>0 and length==(unique|length) and all(.[]; type=="string" and length>0)) and
    (.risk_level=="low" or .risk_level=="medium" or .risk_level=="high") and
    (.required_approval_tier=="low" or .required_approval_tier=="medium" or .required_approval_tier=="high") and
    (.pinned_ref_hash|type=="string" and test("^sha256:[a-f0-9]{64}$"))
  )) and
  ([.mcps[].id] | length==(unique|length)) and
  ([.mcps[].root_path] | length==(unique|length))
'

if [[ -d "$ROOT_DIR/packages/mcps" ]]; then
  fail "packages/mcps" "unsupported MCP root; use control/mcps/<mcp-name>"
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
  while IFS=$'\t' read -r service_id repo_path policy_profile_ref mcp_allowlist_path contract_bundle_ref slo_contract_ref; do
    [[ -n "$service_id" ]] || continue

    check_dir "$repo_path"
    check_exact_files_in_dir "$repo_path" "${SERVICE_PACKAGE_FIXED[@]}"
    check_file "$policy_profile_ref"
    check_file "$mcp_allowlist_path"
    check_file "$contract_bundle_ref"
    check_file "$slo_contract_ref"

    if check_json "$policy_profile_ref"; then
      if ! jq -e '
        (.policy_profile_file|type=="string" and length>0) and
        (.policy_profile|type=="string" and length>0) and
        (.governance_path=="mandatory_bridge")
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
          (.mcp_id|type=="string" and test("^core-[a-z0-9][a-z0-9-]*$")) and
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

    if check_json "$contract_bundle_ref"; then
      if ! jq -e '
        .version=="v0.1" and
        (.service_id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
        (.summary|type=="string" and length>0) and
        (.purpose|type=="string" and length>0) and
        (.owner_role=="architect-owner") and
        (.governance_scope.execution_path=="mandatory_bridge") and
        (.governance_scope.approval_boundary|type=="array" and length>0) and
        (.governance_scope.forbidden_actions|type=="array" and length>0) and
        (.governance_scope.scope_in|type=="array" and length>0) and
        (.governance_scope.scope_out|type=="array" and length>0) and
        (.governance_scope.dependencies|type=="array" and length>0) and
        (.governance_scope.primary_users|type=="array" and length>0) and
        (.runbook.start_conditions|type=="array" and length>0) and
        (.runbook.steady_state|type=="array" and length>0) and
        (.runbook.failure_response|type=="array" and length>0) and
        (.runbook.rollback_reference|type=="array" and length>0) and
        (.risk.tier=="low" or .risk.tier=="medium" or .risk.tier=="high") and
        (.risk.failure_modes|type=="array" and length>0) and
        (.risk.mandatory_controls|type=="array" and length>0) and
        (.data_contract.classification|type=="string" and length>0) and
        (.data_contract.pii_allowed|type=="boolean") and
        (.data_contract.primary_artifacts|type=="array" and length>0) and
        (.data_contract.retention_policy|type=="array" and length>0) and
        (.data_contract.journal_export_policy.mode=="disabled" or .data_contract.journal_export_policy.mode=="conditional" or .data_contract.journal_export_policy.mode=="required") and
        (.data_contract.journal_export_policy.conditions|type=="array" and length>0) and
        (.data_contract.access_controls|type=="array" and length>0) and
        (.integrations.allowed_mcp_ids|type=="array") and
        (.integrations.external_runtime_refs|type=="array") and
        (.integrations.governance_interfaces|type=="array" and length>0) and
        (.slo_notes.common_kpi_set=="governance-core-v1") and
        (.slo_notes.critical_metrics|type=="array" and length>0) and
        (.slo_notes.error_budget|type=="array" and length>0) and
        (.change_log|type=="array" and length>0)
      ' "$ROOT_DIR/$contract_bundle_ref" >/dev/null 2>&1; then
        fail "$contract_bundle_ref" "schema validation failed (schemas/service_contract_bundle.schema.json)"
      fi

      bundle_service_id="$(jq -r '.service_id // ""' "$ROOT_DIR/$contract_bundle_ref")"
      if [[ "$bundle_service_id" != "$service_id" ]]; then
        fail "$contract_bundle_ref" "service_id '$bundle_service_id' does not match registry service id '$service_id'"
      fi

      bundle_target_service="$(jq -r 'if .data_contract.journal_export_policy.target_service == null then "" else .data_contract.journal_export_policy.target_service end' "$ROOT_DIR/$contract_bundle_ref")"
      if [[ -n "$bundle_target_service" && "$bundle_target_service" != "obsidian-mcp" ]]; then
        fail "$contract_bundle_ref" "journal export target must be 'obsidian-mcp' when declared"
      fi

      if json_ready "$MCPS_REG_REL"; then
        while IFS= read -r allowed_mcp_id; do
          [[ -n "$allowed_mcp_id" ]] || continue
          if ! jq -e --arg mcp_id "$allowed_mcp_id" '.mcps | any(.id==$mcp_id)' "$ROOT_DIR/$MCPS_REG_REL" >/dev/null 2>&1; then
            fail "$contract_bundle_ref" "unknown MCP id '$allowed_mcp_id' in integrations.allowed_mcp_ids"
          fi
        done < <(jq -r '.integrations.allowed_mcp_ids[]?' "$ROOT_DIR/$contract_bundle_ref")
      fi

      if ! jq -e '
        if has("experience_contract") then
          (
            (.experience_contract.experience_model|type=="string" and length>0) and
            (.experience_contract.primary_emotion_axis|type=="string" and length>0) and
            (.experience_contract.interaction_axis|type=="string" and length>0) and
            (.experience_contract.core_presence.summary|type=="string" and length>0) and
            (.experience_contract.core_presence.persistent_cues|type=="array" and length>0) and
            (.experience_contract.core_presence.relationship_distance_model|type=="string" and length>0) and
            (.experience_contract.emotional_skins|type=="array" and length>0) and
            (all(.experience_contract.emotional_skins[];
              (.theme_id|type=="string" and test("^[a-z][a-z0-9-]*$")) and
              (.display_name|type=="string" and length>0) and
              (.emotion_profile|type=="array" and length>0) and
              (.visual_profile.signature_motifs|type=="array" and length>0) and
              (.visual_profile.dominant_layers|type=="array" and length>0) and
              (.visual_profile.key_effect_bias|type=="array" and length>0 and length<=2) and
              (.audio_profile.energy|type=="string" and length>0) and
              (.audio_profile.texture|type=="string" and length>0) and
              (.interaction_response_profile.invocation|type=="string" and length>0) and
              (.interaction_response_profile.offering|type=="string" and length>0) and
              (.interaction_response_profile.alignment|type=="string" and length>0) and
              (.result_reveal_style|type=="string" and length>0) and
              (.transition_rules|type=="array" and length>0)
            )) and
            ([.experience_contract.emotional_skins[].theme_id] | length == (unique | length)) and
            (.experience_contract.interaction_ritual.loop|type=="array" and length>0) and
            (.experience_contract.interaction_ritual.input_channels|type=="array" and length>0) and
            (.experience_contract.interaction_ritual.state_machine|type=="array" and length>0) and
            ([.experience_contract.interaction_ritual.state_machine[].state_id] | index("Dormant") != null) and
            ([.experience_contract.interaction_ritual.state_machine[].state_id] | index("Awakening") != null) and
            ([.experience_contract.interaction_ritual.state_machine[].state_id] | index("Attuning") != null) and
            ([.experience_contract.interaction_ritual.state_machine[].state_id] | index("Offering") != null) and
            ([.experience_contract.interaction_ritual.state_machine[].state_id] | index("JudgementBloom") != null) and
            ([.experience_contract.interaction_ritual.state_machine[].state_id] | index("Revelation") != null) and
            ([.experience_contract.interaction_ritual.state_machine[].state_id] | index("Afterglow") != null) and
            (.experience_contract.scene_state_contract.required_fields|type=="array" and length>0) and
            (.experience_contract.scene_state_contract.state_guarantees|type=="array" and length>0) and
            (.experience_contract.interaction_event_model.event_types|type=="array" and length>0) and
            ([.experience_contract.interaction_event_model.event_types[]] | index("invoke_start") != null) and
            ([.experience_contract.interaction_event_model.event_types[]] | index("invoke_commit") != null) and
            ([.experience_contract.interaction_event_model.event_types[]] | index("offering_move") != null) and
            ([.experience_contract.interaction_event_model.event_types[]] | index("offering_commit") != null) and
            ([.experience_contract.interaction_event_model.event_types[]] | index("alignment_shift") != null) and
            ([.experience_contract.interaction_event_model.event_types[]] | index("reveal_accept") != null) and
            ([.experience_contract.interaction_event_model.event_types[]] | index("reenter_ritual") != null) and
            (.experience_contract.visual_modulation_contract.required_fields|type=="array" and length>0) and
            (.experience_contract.visual_modulation_contract.rendering_layers|type=="array" and length>0) and
            (.experience_contract.visual_modulation_contract.form_strategy|type=="array" and length>0) and
            (.experience_contract.visual_modulation_contract.supporting_strategies|type=="array" and length>0) and
            (.experience_contract.test_scenarios|type=="array" and length>0)
          )
        else
          true
        end
      ' "$ROOT_DIR/$contract_bundle_ref" >/dev/null 2>&1; then
        fail "$contract_bundle_ref" "invalid optional experience_contract"
      fi

      if check_json "$mcp_allowlist_path"; then
        if ! jq -e \
          --slurpfile bundle "$ROOT_DIR/$contract_bundle_ref" \
          '(([.allowed_mcps[]?.mcp_id] | sort) == (($bundle[0].integrations.allowed_mcp_ids // []) | sort))' \
          "$ROOT_DIR/$mcp_allowlist_path" >/dev/null 2>&1; then
          fail "$contract_bundle_ref" "integrations.allowed_mcp_ids must match ${mcp_allowlist_path}"
        fi
      fi
    fi

    if check_json "$slo_contract_ref"; then
      if ! jq -e '
        .version=="v0.1" and
        .common_kpi_set=="governance-core-v1" and
        (.kpis|type=="array" and length>=7) and
        ([.kpis[].id] | index("explainability_coverage") != null) and
        ([.kpis[].id] | index("validation_reliability") != null) and
        ([.kpis[].id] | index("operational_latency_p95_ms") != null) and
        ([.kpis[].id] | index("d1_return_rate") != null) and
        ([.kpis[].id] | index("vote_completion_rate") != null) and
        ([.kpis[].id] | index("post_vote_result_open_rate") != null) and
        ([.kpis[].id] | index("llm_fallback_rate") != null)
      ' "$ROOT_DIR/$slo_contract_ref" >/dev/null 2>&1; then
        fail "$slo_contract_ref" "schema validation failed (schemas/service_slo_contract.schema.json)"
      fi
    fi

    cloud_batch_policy_rel="services/${service_id}/cloud_batch.policy.v0.1.json"
    if [[ -f "$ROOT_DIR/$cloud_batch_policy_rel" ]]; then
      validate_jq_contract "$cloud_batch_policy_rel" "schemas/trace_record.schema.json" '
        .version=="v0.1" and
        (.thresholds.token_total|type=="number" and .>0) and
        (.thresholds.max_latency_ms|type=="number" and .>0) and
        (.thresholds.fail_rate|type=="number" and .>=0 and .<=1) and
        (.mode_defaults.strictness=="hybrid" or .mode_defaults.strictness=="strict" or .mode_defaults.strictness=="soft")
      '
    fi
  done < <(jq -r '.services[] | [.id, .repo_path, .policy_profile_ref, .mcp_allowlist_path, .contract_bundle_ref, .slo_contract_ref] | @tsv' "$ROOT_DIR/$SERVICES_REG_REL")
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
  while IFS=$'\t' read -r mcp_id root_path mcp_version required_tier registry_pinned_hash; do
    [[ -n "$mcp_id" ]] || continue

    manifest_rel="$root_path/manifest.json"
    contract_bundle_rel="$root_path/contract.bundle.v0.1.json"
    check_dir "$root_path"
    check_file "$manifest_rel"
    check_file "$contract_bundle_rel"
    check_allowed_entries_in_dir "$root_path" "manifest.json" "contract.bundle.v0.1.json" "versions"
    runtime_binding_rel="$root_path/versions/runtime.binding.v0.1.json"
    check_exact_files_in_dir "$root_path/versions" "runtime.binding.v0.1.json"
    check_file "$runtime_binding_rel"
    check_json "$runtime_binding_rel"
    if check_json "$runtime_binding_rel"; then
      if ! jq -e '
        .version=="v0.1" and
        (.runtime_owner_service|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
        (.runtime_repo_path|type=="string" and length>0) and
        (.invocation_surface|type=="string" and length>0) and
        (.sdk_package|type=="string" and length>0) and
        (.validation_package|type=="string" and length>0) and
        (.tool_names|type=="array" and length>0 and length==(unique|length) and all(.[]; type=="string" and test("^[a-z0-9][a-z0-9._-]*$")))
      ' "$ROOT_DIR/$runtime_binding_rel" >/dev/null 2>&1; then
        fail "$runtime_binding_rel" "schema validation failed (schemas/mcp_runtime_binding.schema.json)"
      fi
    fi

    if check_json "$contract_bundle_rel"; then
      if ! jq -e '
        .version=="v0.1" and
        (.mcp_id|type=="string" and test("^core-[a-z0-9][a-z0-9-]*$")) and
        (.summary|type=="string" and length>0) and
        (.purpose|type=="string" and length>0) and
        (.capability_contract.allowed_operations|type=="array" and length>0 and length==(unique|length)) and
        (.capability_contract.forbidden_expansion|type=="array" and length>0) and
        (.capability_contract.required_approval_tier=="low" or .capability_contract.required_approval_tier=="medium" or .capability_contract.required_approval_tier=="high") and
        (.capability_contract.scope|type=="array" and length>0) and
        (.security_boundary.allowed_inputs|type=="array" and length>0) and
        (.security_boundary.forbidden_inputs|type=="array" and length>0) and
        (.security_boundary.non_goals|type=="array" and length>0) and
        (.security_boundary.controls|type=="array" and length>0) and
        (.evidence_contract.required_refs|type=="array" and length>0) and
        (.evidence_contract.hash_policy|type=="string" and length>0) and
        (.evidence_contract.trace_linkage|type=="string" and length>0) and
        (.runtime_contract.binding_ref|type=="string" and length>0) and
        (.runtime_contract.runtime_owner_service|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
        (.runtime_contract.runtime_repo_path|type=="string" and length>0) and
        (.runtime_contract.invocation_surface|type=="string" and length>0) and
        (.runtime_contract.sdk_package|type=="string" and length>0) and
        (.runtime_contract.validation_package|type=="string" and length>0) and
        (.runtime_contract.tool_names|type=="array" and length>0 and length==(unique|length)) and
        (.change_log|type=="array" and length>0)
      ' "$ROOT_DIR/$contract_bundle_rel" >/dev/null 2>&1; then
        fail "$contract_bundle_rel" "schema validation failed (schemas/mcp_contract_bundle.schema.json)"
      fi

      bundle_mcp_id="$(jq -r '.mcp_id // ""' "$ROOT_DIR/$contract_bundle_rel")"
      if [[ "$bundle_mcp_id" != "$mcp_id" ]]; then
        fail "$contract_bundle_rel" "mcp_id '$bundle_mcp_id' does not match registry id '$mcp_id'"
      fi

      bundle_binding_ref="$(jq -r '.runtime_contract.binding_ref // ""' "$ROOT_DIR/$contract_bundle_rel")"
      if [[ "$bundle_binding_ref" != "$runtime_binding_rel" ]]; then
        fail "$contract_bundle_rel" "runtime_contract.binding_ref must equal ${runtime_binding_rel}"
      fi
    fi

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

      manifest_pinned_hash="$(jq -r '.pinned_ref_hash // ""' "$ROOT_DIR/$manifest_rel")"
      expected_pinned_hash="sha256:$(sha256_file "$ROOT_DIR/$runtime_binding_rel")"
      if [[ "$manifest_pinned_hash" != "$expected_pinned_hash" ]]; then
        fail "$manifest_rel" "manifest pinned_ref_hash must equal runtime binding hash (${expected_pinned_hash})"
      fi
      if [[ "$registry_pinned_hash" != "$expected_pinned_hash" ]]; then
        fail "$MCPS_REG_REL" "registry pinned_ref_hash for MCP '$mcp_id' must equal runtime binding hash (${expected_pinned_hash})"
      fi

      runtime_owner_service="$(jq -r '.runtime_owner_service // ""' "$ROOT_DIR/$runtime_binding_rel")"
      if json_ready "$SERVICES_REG_REL"; then
        if ! jq -e --arg service_id "$runtime_owner_service" '.services | any(.id==$service_id)' "$ROOT_DIR/$SERVICES_REG_REL" >/dev/null 2>&1; then
          fail "$runtime_binding_rel" "runtime_owner_service '$runtime_owner_service' is not registered in ${SERVICES_REG_REL}"
        fi
      fi

      if check_json "$contract_bundle_rel"; then
        if ! jq -e --arg service_id "$runtime_owner_service" '.runtime_contract.runtime_owner_service==$service_id' "$ROOT_DIR/$contract_bundle_rel" >/dev/null 2>&1; then
          fail "$contract_bundle_rel" "runtime_contract.runtime_owner_service does not match ${runtime_binding_rel}"
        fi

        if ! jq -e --arg surface "$(jq -r '.invocation_surface' "$ROOT_DIR/$runtime_binding_rel")" '.runtime_contract.invocation_surface==$surface' "$ROOT_DIR/$contract_bundle_rel" >/dev/null 2>&1; then
          fail "$contract_bundle_rel" "runtime_contract.invocation_surface does not match ${runtime_binding_rel}"
        fi

        if ! jq -e --slurpfile manifest "$ROOT_DIR/$manifest_rel" '
            ((.capability_contract.allowed_operations | sort) == (($manifest[0].capabilities | sort)))
          ' "$ROOT_DIR/$contract_bundle_rel" >/dev/null 2>&1; then
          fail "$contract_bundle_rel" "capability_contract.allowed_operations must match ${manifest_rel}"
        fi
      fi
    fi
  done < <(jq -r '.mcps[] | [.id, .root_path, .version, .required_approval_tier, .pinned_ref_hash] | @tsv' "$ROOT_DIR/$MCPS_REG_REL")
fi

# Every control/mcps/* directory must be in central MCP registry.
if json_ready "$MCPS_REG_REL" && [[ -d "$ROOT_DIR/control/mcps" ]]; then
  while IFS= read -r mcp_dir; do
    mcp_name="$(basename "$mcp_dir")"
    if ! jq -e --arg root_path "control/mcps/${mcp_name}" '.mcps | any(.root_path==$root_path)' "$ROOT_DIR/$MCPS_REG_REL" >/dev/null 2>&1; then
      fail "control/mcps/${mcp_name}" "MCP directory not registered in ${MCPS_REG_REL}"
    fi
  done < <(find "$ROOT_DIR/control/mcps" -mindepth 1 -maxdepth 1 -type d | sort)
fi

if (( errors > 0 )); then
  echo "VALIDATION_FAIL count=${errors}" >&2
  exit 1
fi

echo "VALIDATION_PASS"
