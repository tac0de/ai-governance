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

SERVICE_PACKAGE_OPTIONAL=(
  "agent-roles"
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
  schemas/bootstrap_manifest.schema.json \
  schemas/bootstrap_receipt.schema.json \
  schemas/service_contract_bundle.schema.json \
  schemas/service_slo_contract.schema.json \
  schemas/service_agent_roles.schema.json \
  schemas/service_agent_handoffs.schema.json \
  schemas/service_agent_proposal.schema.json \
  schemas/service_agent_plan.schema.json \
  schemas/service_prompt_strategy.schema.json \
  schemas/service_plan_strategy.schema.json \
  schemas/mcps_registry.schema.json \
  schemas/mcp_allowlist.schema.json \
  schemas/mcp_manifest.schema.json \
  schemas/mcp_contract_bundle.schema.json \
  schemas/mcp_runtime_binding.schema.json \
  schemas/mcp_change_request.schema.json \
  schemas/control_playbook.schema.json \
  schemas/trace_rules.schema.json \
  schemas/mcp_ownership_policy.schema.json \
  schemas/version_promotion_policy.schema.json \
  schemas/link_scan_points.schema.json \
  schemas/department_flow.schema.json \
  schemas/service_kernel.schema.json \
  schemas/launch_readiness.schema.json \
  schemas/cloud_batch_jobs_manifest.schema.json \
  schemas/cloud_batch_results_manifest.schema.json \
  schemas/cloud_batch_verify_verdict.schema.json
  do
  check_json "$schema_rel"
done

for governance_rel in \
  control/agents/role.catalog.v0.4.json \
  control/agents/departments.v0.5.json \
  control/agents/role.catalog.v0.5.json \
  control/registry/lanes.v0.4.json \
  control/registry/temporary-links.v0.4.json \
  control/registry/linked-services.v0.4.json \
  control/registry/capabilities.v0.4.json \
  control/registry/version-promotion.v0.4.json \
  control/registry/link-scan-points.v0.5.json \
  control/registry/temporary-links.v0.5.json \
  control/registry/department-flow.v0.5.json \
  control/registry/service-kernel.v0.5.json \
  control/registry/linked-services.v0.5.json \
  control/registry/launch-readiness.v0.5.json
  do
  check_json "$governance_rel"
done

# Control room fixed document sets (freeze line).
check_exact_files_in_dir "control/registry" \
  "org.v0.1.json" \
  "services.v0.1.json" \
  "mcps.v0.1.json" \
  "lanes.v0.4.json" \
  "temporary-links.v0.4.json" \
  "linked-services.v0.4.json" \
  "capabilities.v0.4.json" \
  "version-promotion.v0.4.json" \
  "link-scan-points.v0.5.json" \
  "temporary-links.v0.5.json" \
  "department-flow.v0.5.json" \
  "service-kernel.v0.5.json" \
  "linked-services.v0.5.json" \
  "launch-readiness.v0.5.json"

check_exact_files_in_dir "control/playbooks" \
  "incident.v0.1.json" \
  "change-management.v0.1.json" \
  "onboarding.v0.1.json"

check_exact_files_in_dir "control/benchmarks" \
  "efficiency_benchmark_spec.v0.1.json"

check_exact_files_in_dir "control/agents" \
  "departments.v0.1.json" \
  "role.catalog.v0.4.json" \
  "departments.v0.5.json" \
  "role.catalog.v0.5.json"

check_exact_files_in_dir "control/prompts" \
  "library.v0.1.json"

check_exact_files_in_dir "control/specs" \
  "opcodes.v0.1.json" \
  "trace_rules.v0.1.json"

check_exact_files_in_dir "control/templates/service" "contract.bundle.template.v0.1.json"
check_exact_files_in_dir "control/templates/mcp" "contract.bundle.template.v0.1.json"
check_exact_files_in_dir "control/templates/service-bootstrap" \
  "bootstrap.manifest.template.v0.1.json" \
  "service.contract.bundle.template.v0.1.json" \
  "agent.roles.template.v0.1.json" \
  "agent.handoffs.template.v0.1.json" \
  "prompt.strategy.template.v0.1.json" \
  "plan.strategy.template.v0.1.json" \
  "bootstrap.receipt.template.v0.1.json" \
  "repo.readme.template.v0.1.json"

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
    (.catalog_role=="archived-seed-example") and
    (.owner|type=="string" and length>0) and
    (.seed_path|type=="string" and test("^services/[a-z0-9][a-z0-9-]*$")) and
    (.bootstrap_profile=="standard" or .bootstrap_profile=="ritual-uiux") and
    (.contract_bundle_ref|type=="string" and length>0) and
    (.agent_roles_ref|type=="string" and length>0) and
    (.agent_handoffs_ref|type=="string" and length>0) and
    (.default_policy_profile_ref|type=="string" and length>0) and
    (.default_mcp_allowlist_ref|type=="string" and length>0) and
    (.default_slo_contract_ref|type=="string" and length>0) and
    (.notes|type=="array" and length>0)
  )) and
  ([.services[].id] | length==(unique|length)) and
  ([.services[].seed_path] | length==(unique|length)) and
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

validate_jq_contract "control/registry/version-promotion.v0.4.json" "schemas/version_promotion_policy.schema.json" '
  .version=="v0.4" and
  (.policy_id=="version-promotion") and
  (.definition.pre_v1|type=="string" and length>0) and
  (.definition.v1_0|type=="string" and length>0) and
  (.gates.required_all|type=="array" and length>=3) and
  (all(.gates.required_all[];
    (.gate_id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
    (.evidence_type|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
    (.rule=="at_least_one") and
    (.notes|type=="array" and length>0)
  )) and
  (.gates.required_metrics|type=="array" and length>=2) and
  (all(.gates.required_metrics[];
    (.metric_id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
    (.operator==">=" or .operator=="==") and
    (.value|type=="number")
  )) and
  (.promotion_flow|type=="array" and length>0) and
  (.anti_patterns|type=="array" and length>0)
'

validate_jq_contract "control/registry/link-scan-points.v0.5.json" "schemas/link_scan_points.schema.json" '
  .version=="v0.5" and
  (.model=="link-scan-catalog") and
  (.scan_points|type=="array" and length==4) and
  ([.scan_points[].id] | length==(unique|length)) and
  ([.scan_points[].order] | length==(unique|length)) and
  ([.scan_points[].id]) as $scan_ids |
  (all(.lane_minimums.exploration[]; $scan_ids | index(.) != null)) and
  (all(.lane_minimums.production[]; $scan_ids | index(.) != null)) and
  ((.lane_minimums.production | index("pre-release-scan")) != null)
'

if check_json "control/registry/temporary-links.v0.5.json"; then
  if ! jq -e '
    .version=="v0.5" and
    (.link_contract.phases | type=="array" and length==5) and
    (.link_contract.phase_scan_map | type=="array" and length==5) and
    ([.link_contract.phase_scan_map[].phase] | length==(unique|length)) and
    (all(.link_contract.phase_scan_map[];
      (.phase=="request" or .phase=="grant" or .phase=="execute-local" or .phase=="review" or .phase=="release") and
      (.required_scans | type=="array" and length>0 and all(.[]; .=="intake-scan" or .=="pre-exec-scan" or .=="post-exec-scan" or .=="pre-release-scan"))
    )) and
    (.link_contract.completion_rule.missing_scan_status=="incomplete") and
    (.link_contract.completion_rule.production_requires_scan=="pre-release-scan") and
    (.link_contract.completion_rule.required_scans_for_completed | type=="array" and length==4) and
    ((.link_contract.completion_rule.required_scans_for_completed | index("intake-scan")) != null) and
    ((.link_contract.completion_rule.required_scans_for_completed | index("pre-exec-scan")) != null) and
    ((.link_contract.completion_rule.required_scans_for_completed | index("post-exec-scan")) != null) and
    ((.link_contract.completion_rule.required_scans_for_completed | index("pre-release-scan")) != null) and
    (.link_contract.residue_policy.link_residue_check_must_be=="none") and
    (.link_contract.residue_policy.incomplete_blocks_release==true) and
    (.link_contract.residue_policy.open_residue_blocks_release==true) and
    (.link_contract.defaults.link_scope=="ephemeral") and
    (.link_contract.defaults.runtime_log_owner=="service-local") and
    (.link_contract.defaults.central_receives_raw_logs==false) and
    (.link_contract.defaults.initial_status=="requested") and
    (.link_contract.hard_rules | type=="array" and length>=5)
  ' "$ROOT_DIR/control/registry/temporary-links.v0.5.json" >/dev/null 2>&1; then
    fail "control/registry/temporary-links.v0.5.json" "schema validation failed (inline v0.5 temporary-link rules)"
  fi
fi

if check_json "control/agents/departments.v0.5.json"; then
  if ! jq -e '
    .version=="v0.5" and
    (.model=="department-state-machine") and
    (.departments | type=="array" and length==5) and
    ([.departments[].id] | length==(unique|length)) and
    (all(.departments[];
      (.id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
      (.name|type=="string" and length>0) and
      (.purpose|type=="string" and length>0) and
      (.default_prompt_set|type=="string" and length>0) and
      (.supports_roles|type=="array" and length>0) and
      (.allowed_outputs|type=="array" and length>0)
    ))
  ' "$ROOT_DIR/control/agents/departments.v0.5.json" >/dev/null 2>&1; then
    fail "control/agents/departments.v0.5.json" "schema validation failed (inline v0.5 department rules)"
  fi
fi

if check_json "control/agents/role.catalog.v0.5.json"; then
  if ! jq -e '
    .version=="v0.5" and
    (.model=="casting-director-stateful") and
    (.roles | type=="array" and length==6) and
    ([.roles[].id] | length==(unique|length)) and
    (all(.roles[];
      (.id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
      (.name|type=="string" and length>0) and
      (.mission|type=="string" and length>0) and
      (.default_lane=="exploration" or .default_lane=="production") and
      (.leaseable|type=="boolean") and
      (.home_department|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
      (.allowed_departments|type=="array" and length>0) and
      (.outputs|type=="array" and length>0)
    ))
  ' "$ROOT_DIR/control/agents/role.catalog.v0.5.json" >/dev/null 2>&1; then
    fail "control/agents/role.catalog.v0.5.json" "schema validation failed (inline v0.5 role rules)"
  fi
fi

validate_jq_contract "control/registry/department-flow.v0.5.json" "schemas/department_flow.schema.json" '
  .version=="v0.5" and
  (.model=="department-handoff-graph") and
  (.terminal_states | type=="array" and length==1) and
  ((.terminal_states | index("released")) != null) and
  (.max_same_department_reentries_before_human_approval==2) and
  (.allowed_transitions | type=="array" and length==10) and
  (.forbidden_shortcuts | type=="array" and length==3) and
  (.human_override_conditions | type=="array" and length>0)
'

validate_jq_contract "control/registry/service-kernel.v0.5.json" "schemas/service_kernel.schema.json" '
  .version=="v0.5" and
  (.model=="linked-service-kernel") and
  (.required_root_entries | type=="array" and length==4) and
  (.required_governance_entries | type=="array" and length==4) and
  (.profiles | type=="array" and length==3) and
  ([.profiles[].profile_id] | length==(unique|length)) and
  ((.profiles | map(.profile_id) | index("web-runtime")) != null) and
  ((.profiles | map(.profile_id) | index("tool-runtime")) != null) and
  ((.profiles | map(.profile_id) | index("worker-runtime")) != null) and
  (.rules | type=="array" and length>0)
'

if check_json "control/registry/linked-services.v0.5.json"; then
  if ! jq -e '
    .version=="v0.5" and
    (.model=="linked-service-catalog") and
    (.services | type=="array" and length>0) and
    ([.services[].id] | length==(unique|length)) and
    (all(.services[];
      (.id|type=="string" and test("^[a-z0-9][a-z0-9-]*$")) and
      (.owner_role|type=="string" and length>0) and
      (.runtime_repo_path|type=="string" and length>0) and
      (.log_owner=="service-local") and
      (.governance_relationship=="temporary-link-preferred") and
      (.service_root_profile|type=="string" and length>0) and
      (.service_contract_ref|type=="string" and length>0) and
      (.governance_kernel_status=="planned" or .governance_kernel_status=="present" or .governance_kernel_status=="incomplete") and
      (.last_link_scan_ref=="none" or (.last_link_scan_ref|type=="string" and length>0)) and
      (.launch_readiness_ref==null or (.launch_readiness_ref|type=="string" and length>0)) and
      (.notes|type=="array" and length>0)
    ))
  ' "$ROOT_DIR/control/registry/linked-services.v0.5.json" >/dev/null 2>&1; then
    fail "control/registry/linked-services.v0.5.json" "schema validation failed (inline v0.5 linked-service rules)"
  fi
fi

validate_jq_contract "control/registry/launch-readiness.v0.5.json" "schemas/launch_readiness.schema.json" '
  .version=="v0.5" and
  (.policy_id=="launch-readiness") and
  (.definition.pre_launch|type=="string" and length>0) and
  (.definition.launch_ready|type=="string" and length>0) and
  (.gates.required_all|type=="array" and length>=4) and
  (.gates.required_checks|type=="array" and length>=3) and
  (.gates.freshness_window_days|type=="number" and .>0) and
  (.promotion_effect.allows_release_review_signal=="promotable") and
  (.promotion_effect.blocks_v1_without_version_promotion==true) and
  (.anti_patterns|type=="array" and length>0)
'

if json_ready "control/agents/departments.v0.5.json" && json_ready "control/agents/role.catalog.v0.5.json"; then
  if ! jq -n \
    --slurpfile departments "$ROOT_DIR/control/agents/departments.v0.5.json" \
    --slurpfile roles "$ROOT_DIR/control/agents/role.catalog.v0.5.json" '
      ($departments[0].departments | map(.id)) as $dept_ids |
      all($roles[0].roles[];
        . as $role |
        ($role.home_department as $home | ($dept_ids | index($home)) != null) and
        ($role.allowed_departments | all(.[]; . as $allowed | ($dept_ids | index($allowed)) != null))
      )
    ' >/dev/null 2>&1; then
    fail "control/agents/role.catalog.v0.5.json" "role departments must resolve against departments.v0.5.json"
  fi
fi

if json_ready "control/agents/departments.v0.5.json" && json_ready "control/registry/department-flow.v0.5.json"; then
  if ! jq -n \
    --slurpfile departments "$ROOT_DIR/control/agents/departments.v0.5.json" \
    --slurpfile flow "$ROOT_DIR/control/registry/department-flow.v0.5.json" '
      ($departments[0].departments | map(.id)) as $dept_ids |
      ($flow[0].terminal_states) as $terminal |
      all($flow[0].allowed_transitions[];
        .from as $from |
        .to as $to |
        ($dept_ids | index($from)) != null and
        ((($dept_ids + $terminal) | index($to)) != null)
      ) and
      all($flow[0].forbidden_shortcuts[];
        .from as $from |
        .to as $to |
        ($dept_ids | index($from)) != null and
        ((($dept_ids + $terminal) | index($to)) != null)
      )
    ' >/dev/null 2>&1; then
    fail "control/registry/department-flow.v0.5.json" "department flow references must resolve against departments.v0.5.json"
  fi
fi

if json_ready "control/registry/service-kernel.v0.5.json" && json_ready "control/registry/linked-services.v0.5.json"; then
  if ! jq -n \
    --slurpfile kernel "$ROOT_DIR/control/registry/service-kernel.v0.5.json" \
    --slurpfile services "$ROOT_DIR/control/registry/linked-services.v0.5.json" '
      ($kernel[0].profiles | map(.profile_id)) as $profile_ids |
      all($services[0].services[];
        .service_root_profile as $profile |
        .service_contract_ref as $contract_ref |
        ($profile_ids | index($profile)) != null and
        ($contract_ref == "governance/service.contract.json")
      )
    ' >/dev/null 2>&1; then
    fail "control/registry/linked-services.v0.5.json" "linked service profiles must resolve against service-kernel.v0.5.json"
  fi
fi

if [[ -d "$ROOT_DIR/packages/mcps" ]]; then
  fail "packages/mcps" "unsupported MCP root; use control/mcps/<mcp-name>"
fi

# Seed catalog consistency checks.
if json_ready "$SERVICES_REG_REL"; then
  if ! jq -e '
    ([.services[].id] | length == (unique | length)) and
    ([.services[].seed_path] | length == (unique | length))
  ' "$ROOT_DIR/$SERVICES_REG_REL" >/dev/null 2>&1; then
    fail "$SERVICES_REG_REL" "seed ids and seed paths must be unique"
  fi

  while IFS=$'\t' read -r service_id seed_path contract_bundle_ref agent_roles_ref agent_handoffs_ref default_policy_profile_ref default_mcp_allowlist_ref default_slo_contract_ref; do
    [[ -n "$service_id" ]] || continue

    check_dir "$seed_path"
    check_file "$contract_bundle_ref"
    check_file "$agent_roles_ref"
    check_file "$agent_handoffs_ref"
    check_file "$default_policy_profile_ref"
    check_file "$default_mcp_allowlist_ref"
    check_file "$default_slo_contract_ref"
  done < <(
    jq -r '
      .services[] | [
        .id,
        .seed_path,
        .contract_bundle_ref,
        .agent_roles_ref,
        .agent_handoffs_ref,
        .default_policy_profile_ref,
        .default_mcp_allowlist_ref,
        .default_slo_contract_ref
      ] | @tsv
    ' "$ROOT_DIR/$SERVICES_REG_REL"
  )
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
