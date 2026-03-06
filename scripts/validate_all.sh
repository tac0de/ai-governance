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

sha256_of_file() {
  local file_path="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file_path" | awk '{print $1}'
  else
    shasum -a 256 "$file_path" | awk '{print $1}'
  fi
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

check_executable() {
  local rel_path="$1"
  if ! check_file "$rel_path"; then
    return 1
  fi
  if [[ ! -x "$ROOT_DIR/$rel_path" ]]; then
    fail "$rel_path" "expected executable bit"
    return 1
  fi
  return 0
}

check_shell_syntax() {
  local rel_path="$1"
  if ! check_file "$rel_path"; then
    return 1
  fi
  if ! bash -n "$ROOT_DIR/$rel_path" >/dev/null 2>&1; then
    fail "$rel_path" "invalid shell syntax"
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

check_sha256_baseline() {
  local rel_path="$1"
  local line
  local expected_hash
  local target_path
  local actual_hash

  if ! check_file "$rel_path"; then
    return
  fi

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue

    expected_hash="${line%%  *}"
    target_path="${line#*  }"

    if [[ "$target_path" == "$rel_path" ]]; then
      fail "$rel_path" "baseline file must not self-reference"
      continue
    fi

    if [[ ! -f "$ROOT_DIR/$target_path" ]]; then
      fail "$rel_path" "baseline target missing: $target_path"
      continue
    fi

    actual_hash="$(sha256_of_file "$ROOT_DIR/$target_path")"
    if [[ "$actual_hash" != "$expected_hash" ]]; then
      fail "$rel_path" "hash drift for $target_path"
    fi
  done < "$ROOT_DIR/$rel_path"
}

require jq

bash "$ROOT_DIR/scripts/scan_repo_hygiene.sh"

check_sha256_baseline "docs/baseline.v0.7.sha256"

markdown_files="$(cd "$ROOT_DIR" && rg --files -g '*.md' || true)"
markdown_count="$(printf '%s\n' "$markdown_files" | sed '/^$/d' | wc -l | tr -d ' ')"
if [[ "$markdown_count" -ne 1 || "$markdown_files" != "README.md" ]]; then
  fail "README.md" "README-only markdown policy violated"
fi

check_exact_files_in_dir "scripts" \
  "scan_repo_hygiene.sh" \
  "trace_append.sh" \
  "validate_all.sh"

check_exact_files_in_dir ".github/workflows" \
  "deterministic-governance.yml" \
  "github-pages.yml"

check_file "LICENSE"
check_file "README.md"
check_file "docs/index.html"
check_file "docs/assets/site.css"
check_file "docs/assets/site.js"

check_allowed_entries_in_dir "control" "registry" "specs"
check_exact_files_in_dir "control/registry" \
  "audit-bundle.v0.7.json" \
  "customer-tenant.v0.7.json" \
  "governance-protocol.v0.7.json" \
  "incident-exception.v0.7.json" \
  "launch-readiness.v0.7.json" \
  "link-approval-receipt.v0.7.json" \
  "link-auth-contract.v0.7.json" \
  "shell-entrypoints.v0.7.json" \
  "support-ops-readiness.v0.7.json" \
  "revenue-readiness.v0.7.json" \
  "link-scan-points.v0.7.json" \
  "service-diet.v0.7.json" \
  "service-kernel.v0.7.json" \
  "service-normalization.v0.7.json" \
  "temporary-links.v0.7.json" \
  "version-promotion.v0.7.json"
check_exact_files_in_dir "control/specs" \
  "trace_rules.v0.7.json"

check_exact_files_in_dir "policies" \
  "external_execution_boundary.v0.7.json"

check_allowed_entries_in_dir "packs" \
  "audit-bundle" \
  "link-kit" \
  "service-bootstrap"
check_exact_files_in_dir "packs/service-bootstrap" \
  "install.sh" \
  "manifest.json" \
  "payload.json"
check_exact_files_in_dir "packs/link-kit" \
  "approval.receipt.json" \
  "auth.contract.json" \
  "gate.approval.json" \
  "install.sh" \
  "link.grant.json" \
  "link.request.json" \
  "link.route.json" \
  "manifest.json" \
  "residue.check.json" \
  "review.outcome.json" \
  "scan.baseline.json" \
  "scan.boundary-seal.json" \
  "scan.intake-contract.json" \
  "scan.plan.json" \
  "scan.pre-release.json" \
  "scan.review-gate.json" \
  "status.json"
check_exact_files_in_dir "packs/audit-bundle" \
  "bundle.template.json" \
  "manifest.json" \
  "render.sh"

check_exact_files_in_dir "schemas" \
  "audit_bundle.schema.json" \
  "customer_tenant.schema.json" \
  "governance_protocol.schema.json" \
  "incident_exception.schema.json" \
  "launch_readiness.schema.json" \
  "link_approval_receipt.schema.json" \
  "link_auth_contract.schema.json" \
  "link_scan_points.schema.json" \
  "revenue_readiness.schema.json" \
  "reflection_packet.schema.json" \
  "service_kernel.schema.json" \
  "shell_entrypoints.schema.json" \
  "support_ops_readiness.schema.json" \
  "trace_record.schema.json" \
  "trace_rules.schema.json" \
  "version_promotion_policy.schema.json"

for schema_rel in \
  schemas/audit_bundle.schema.json \
  schemas/customer_tenant.schema.json \
  schemas/governance_protocol.schema.json \
  schemas/incident_exception.schema.json \
  schemas/launch_readiness.schema.json \
  schemas/link_approval_receipt.schema.json \
  schemas/link_auth_contract.schema.json \
  schemas/link_scan_points.schema.json \
  schemas/revenue_readiness.schema.json \
  schemas/reflection_packet.schema.json \
  schemas/service_kernel.schema.json \
  schemas/shell_entrypoints.schema.json \
  schemas/support_ops_readiness.schema.json \
  schemas/trace_record.schema.json \
  schemas/trace_rules.schema.json \
  schemas/version_promotion_policy.schema.json
do
  check_json "$schema_rel"
done

for policy_rel in \
  policies/external_execution_boundary.v0.7.json
do
  check_json "$policy_rel"
done

for pack_rel in \
  packs/service-bootstrap/manifest.json \
  packs/service-bootstrap/payload.json \
  packs/link-kit/manifest.json \
  packs/audit-bundle/bundle.template.json \
  packs/audit-bundle/manifest.json
do
  check_json "$pack_rel"
done

for shell_rel in \
  scripts/scan_repo_hygiene.sh \
  scripts/trace_append.sh \
  scripts/validate_all.sh \
  packs/service-bootstrap/install.sh \
  packs/link-kit/install.sh \
  packs/audit-bundle/render.sh
do
  check_shell_syntax "$shell_rel"
done

for executable_rel in \
  packs/service-bootstrap/install.sh \
  packs/link-kit/install.sh \
  packs/audit-bundle/render.sh
do
  check_executable "$executable_rel"
done

for governance_rel in \
  control/registry/audit-bundle.v0.7.json \
  control/registry/customer-tenant.v0.7.json \
  control/registry/governance-protocol.v0.7.json \
  control/registry/incident-exception.v0.7.json \
  control/specs/trace_rules.v0.7.json \
  control/registry/launch-readiness.v0.7.json \
  control/registry/link-approval-receipt.v0.7.json \
  control/registry/link-auth-contract.v0.7.json \
  control/registry/link-scan-points.v0.7.json \
  control/registry/revenue-readiness.v0.7.json \
  control/registry/service-diet.v0.7.json \
  control/registry/service-kernel.v0.7.json \
  control/registry/service-normalization.v0.7.json \
  control/registry/shell-entrypoints.v0.7.json \
  control/registry/support-ops-readiness.v0.7.json \
  control/registry/temporary-links.v0.7.json \
  control/registry/version-promotion.v0.7.json
do
  check_json "$governance_rel"
done

validate_jq_contract "policies/external_execution_boundary.v0.7.json" "schemas/trace_rules.schema.json" '
  .version=="v0.7" and
  .policy_id=="external-execution-boundary" and
  (.central_allows|type=="array" and length==5) and
  (.central_forbids|type=="array" and length==4) and
  (.service_runtime_rule|type=="array" and length==5) and
  ((.central_allows | map(test("Repository-wide read scans")) | any)) and
  ((.central_allows | map(test("cleanup outside governance/")) | any)) and
  ((.central_forbids | map(test("outside governance/")) | any)) and
  ((.service_runtime_rule | map(test("permits the target scope")) | any)) and
  (.language_policy.required_core==["json","yaml","sh"]) and
  (.language_policy.allowed_optional==["py"]) and
  (.language_policy.excluded_in_v0_7==["rs","rust"])
'

validate_jq_contract "control/specs/trace_rules.v0.7.json" "schemas/trace_rules.schema.json" '
  .version=="v0.7" and
  (.append_only==true) and
  (.hash_reference_required==true) and
  (.allowed_record_types|type=="array" and length==9) and
  ((.allowed_record_types | index("reflection_packet")) != null) and
  ((.allowed_record_types | index("protocol_chain_packet")) != null) and
  ((.allowed_record_types | index("shell_execution_receipt")) != null) and
  ((.allowed_record_types | index("collaboration_ideation_packet")) != null) and
  ((.allowed_record_types | index("revenue_signal_packet")) != null) and
  (.retention_model.primary_store=="service-local-governance/dtp/") and
  (.retention_model.export_path=="service-local-governance/dtp/api-sync/") and
  (.dtp.root_path=="governance/dtp/") and
  (.dtp.required_paths|type=="array" and length==3) and
  (.protocol_chain_rules.required_record_types|type=="array" and length==4) and
  ((.protocol_chain_rules.required_record_types | index("protocol_chain_packet")) != null) and
  (.reflection_gate.required_fields|type=="array" and length==8) and
  ((.reflection_gate.required_fields | index("problem_statement")) != null) and
  ((.reflection_gate.required_fields | index("evidence_refs")) != null) and
  ((.reflection_gate.required_fields | index("root_cause_chain")) != null) and
  ((.reflection_gate.required_fields | index("fix_action")) != null) and
  ((.reflection_gate.required_fields | index("owner")) != null) and
  ((.reflection_gate.required_fields | index("due_date_ref")) != null) and
  ((.reflection_gate.required_fields | index("severity")) != null) and
  ((.reflection_gate.required_fields | index("status")) != null) and
  (.revenue_signal_rules.required_fields|type=="array" and length==8) and
  ((.revenue_signal_rules.required_fields | index("service_value_unit")) != null) and
  (.telemetry_sync_boundary.transport=="http-api") and
  (.telemetry_sync_boundary.ownership=="service-local")
'

validate_jq_contract "control/registry/service-kernel.v0.7.json" "schemas/service_kernel.schema.json" '
  .version=="v0.7" and
  (.required_root_entries|length==6) and
  (.required_governance_entries|length==15) and
  (.required_orchestration_entries|length==6) and
  (.required_prompt_entries|length==7) and
  ((.rules | map(test("governance/ surface only")) | any)) and
  ((.rules | map(test("Whole-repository read scans")) | any)) and
  ((.rules | map(test("auth.contract.json")) | any)) and
  ((.rules | map(test("governance protocol chain")) | any)) and
  ((.required_governance_entries | map(.path) | index("governance/VERSION")) != null) and
  ((.required_governance_entries | map(.path) | index("governance/plan.json")) != null) and
  ((.required_orchestration_entries | map(.path) | index("orchestration/architecture.blueprint.yaml")) != null) and
  ((.required_orchestration_entries | map(.path) | index("orchestration/shell.contract.json")) != null) and
  ((.required_prompt_entries | map(.path) | index("prompts/agent-system.md")) != null) and
  ((.required_prompt_entries | map(.path) | index("prompts/collaboration-ideation.md")) != null) and
  ((.required_governance_entries | map(.path) | index("governance/monitoring/service.snapshot.json")) != null) and
  ((.required_governance_entries | map(.path) | index("governance/monitoring/hygiene.report.json")) != null)
'

validate_jq_contract "control/registry/governance-protocol.v0.7.json" "schemas/governance_protocol.schema.json" '
  .version=="v0.7" and
  .model=="governance-protocol" and
  (.stages|length==8) and
  ((.stages | map(.stage_id) | index("agent_layer")) != null) and
  ((.stages | map(.stage_id) | index("prompt_bundle")) != null) and
  ((.stages | map(.stage_id) | index("orchestration_layer")) != null) and
  ((.stages | map(.stage_id) | index("architecture_layer")) != null) and
  ((.stages | map(.stage_id) | index("shell_execution_layer")) != null) and
  ((.stages | map(.stage_id) | index("human_agent_collaboration_layer")) != null) and
  ((.stages | map(.stage_id) | index("dtp_layer")) != null) and
  ((.stages | map(.stage_id) | index("governance_verdict_layer")) != null) and
  (.invariants|length==5)
'

validate_jq_contract "control/registry/customer-tenant.v0.7.json" "schemas/customer_tenant.schema.json" '
  .version=="v0.7" and
  .model=="service-customer" and
  (.required_fields|length==9) and
  ((.required_fields | index("customer_id")) != null) and
  ((.required_fields | index("policy_bundle_id")) != null) and
  ((.required_fields | index("approval_owner")) != null) and
  (.support_tiers|length==3) and
  ((.support_tiers | index("standard")) != null) and
  ((.support_tiers | index("priority")) != null) and
  ((.support_tiers | index("strategic")) != null)
'

validate_jq_contract "control/registry/audit-bundle.v0.7.json" "schemas/audit_bundle.schema.json" '
  .version=="v0.7" and
  .model=="audit-bundle" and
  (.required_fields|length==12) and
  ((.required_fields | index("auth_contract_ref")) != null) and
  ((.required_fields | index("approval_receipt_ref")) != null) and
  ((.required_fields | index("baseline_summary_ref")) != null) and
  ((.required_fields | index("release_verdict_ref")) != null) and
  ((.required_fields | index("reflection_summary_ref")) != null) and
  ((.required_fields | index("policy_bundle_refs")) != null) and
  ((.required_fields | index("protocol_chain_refs")) != null) and
  ((.export_format_values | index("json-bundle")) != null)
'

validate_jq_contract "control/registry/incident-exception.v0.7.json" "schemas/incident_exception.schema.json" '
  .version=="v0.7" and
  .model=="incident-exception" and
  (.required_fields|length==12) and
  ((.required_fields | index("expires_at_ref")) != null) and
  ((.required_fields | index("rollback_ref")) != null) and
  ((.exception_type_values | index("emergency-override")) != null)
'

validate_jq_contract "control/registry/support-ops-readiness.v0.7.json" "schemas/support_ops_readiness.schema.json" '
  .version=="v0.7" and
  .model=="support-ops-readiness" and
  (.required_fields|length==8) and
  ((.required_fields | index("support_tier")) != null) and
  ((.required_fields | index("sla_class")) != null) and
  ((.required_fields | index("billing_readiness_status")) != null)
'

validate_jq_contract "control/registry/shell-entrypoints.v0.7.json" "schemas/shell_entrypoints.schema.json" '
  .version=="v0.7" and
  .model=="shell-entrypoints" and
  (.commands|length==4) and
  ((.commands | map(.command_id) | index("gov-plan")) != null) and
  ((.commands | map(.command_id) | index("gov-apply")) != null) and
  ((.commands | map(.command_id) | index("gov-gate")) != null) and
  ((.commands | map(.command_id) | index("gov-trace")) != null)
'

validate_jq_contract "control/registry/link-auth-contract.v0.7.json" "schemas/link_auth_contract.schema.json" '
  .version=="v0.7" and
  .model=="link-auth-contract" and
  (.required_fields|length==8) and
  ((.required_fields | index("client_id")) != null) and
  ((.required_fields | index("key_id")) != null) and
  ((.required_fields | index("allowed_scopes")) != null) and
  (.status_values==["active","revoked","expired"]) and
  ((.scope_catalog | index("repo-read")) != null) and
  ((.scope_catalog | index("cleanup-apply")) != null)
'

validate_jq_contract "control/registry/link-approval-receipt.v0.7.json" "schemas/link_approval_receipt.schema.json" '
  .version=="v0.7" and
  .model=="link-approval-receipt" and
  (.required_fields|length==11) and
  ((.required_fields | index("approved_mutation_scope")) != null) and
  ((.required_fields | index("allowed_cleanup_targets")) != null) and
  ((.required_fields | index("rollback_note_ref")) != null) and
  (.verdict_values==["approved","rejected","expired"])
'

validate_jq_contract "control/registry/revenue-readiness.v0.7.json" "schemas/revenue_readiness.schema.json" '
  .version=="v0.7" and
  .model=="revenue-readiness" and
  (.required_fields|length==8) and
  ((.required_fields | index("service_value_unit")) != null) and
  ((.required_fields | index("buyer_problem_statement")) != null) and
  ((.required_fields | index("revenue_evidence_refs")) != null) and
  (.commercial_readiness_status_values|length==5) and
  ((.delivery_modes | index("managed-service")) != null)
'

validate_jq_contract "control/registry/link-scan-points.v0.7.json" "schemas/link_scan_points.schema.json" '
  .version=="v0.7" and
  (.scan_points|length==6) and
  ((.scan_points[] | select(.id=="intake-contract-scan") | .required_fields | index("auth_contract_ref")) != null) and
  ((.scan_points[] | select(.id=="intake-contract-scan") | .required_fields | index("scan_root_scope")) != null) and
  ((.scan_points[] | select(.id=="plan-scan") | .required_fields | index("approved_mutation_scope")) != null) and
  ((.scan_points[] | select(.id=="plan-scan") | .required_fields | index("approval_receipt_ref")) != null) and
  ((.scan_points[] | select(.id=="review-gate-scan") | .required_fields | index("cleanup_receipt_ref")) != null) and
  ((.scan_points[] | select(.id=="pre-release-scan") | .required_fields | index("reflection_gate_status")) != null)
'

validate_jq_contract "control/registry/temporary-links.v0.7.json" "schemas/link_scan_points.schema.json" '
  .version=="v0.7" and
  (.link_contract.phases|length==6) and
  (.link_contract.defaults.governance_attach_mode=="governance-folder-only") and
  (.link_contract.defaults.scan_root_scope=="repository-wide-read") and
  ((.link_contract.defaults.central_receives_only | index("auth_contract")) != null) and
  ((.link_contract.defaults.central_receives_only | index("approval_receipt")) != null) and
  ((.link_contract.kit_structure.required_files | index("auth.contract.json")) != null) and
  ((.link_contract.kit_structure.required_files | index("approval.receipt.json")) != null) and
  ((.link_contract.hard_rules | map(test("Repository-wide read scans")) | any)) and
  ((.link_contract.hard_rules | map(test("active auth contract")) | any)) and
  ((.link_contract.hard_rules | map(test("outside governance/")) | any))
'

validate_jq_contract "control/registry/service-diet.v0.7.json" "schemas/trace_rules.schema.json" '
  .version=="v0.7" and
  (.required_outputs|type=="array" and length==6) and
  ((.required_outputs | index("cleanup_receipt_ref")) != null) and
  ((.hard_rules | map(test("whole repository")) | any)) and
  ((.hard_rules | map(test("approved mutation scope")) | any))
'

validate_jq_contract "control/registry/service-normalization.v0.7.json" "schemas/trace_rules.schema.json" '
  .version=="v0.7" and
  (.required_phases|length==6) and
  ((.required_phases[] | select(.phase_id=="intake") | .required_artifacts | index("auth_contract_ref")) != null) and
  ((.required_phases[] | select(.phase_id=="kernel-alignment") | .required_artifacts | index("governance_attach_mode")) != null) and
  ((.required_phases[] | select(.phase_id=="release") | .required_artifacts | index("approval_receipt_ref")) != null) and
  ((.hard_rules | map(test("whole repository")) | any)) and
  ((.hard_rules | map(test("outside governance/")) | any))
'

validate_jq_contract "control/registry/launch-readiness.v0.7.json" "schemas/launch_readiness.schema.json" '
  .version=="v0.7" and
  ((.gates.required_checks | map(.check_id) | index("baseline-recorded")) != null) and
  ((.gates.required_checks | map(.check_id) | index("plan-approved")) != null) and
  ((.gates.required_checks | map(.check_id) | index("apply-boundary-sealed")) != null) and
  ((.gates.required_checks | map(.check_id) | index("auth-contract-valid")) != null) and
  ((.gates.required_checks | map(.check_id) | index("approval-receipt-current")) != null) and
  ((.gates.required_checks | map(.check_id) | index("cleanup-scope-approved")) != null) and
  ((.gates.required_checks | map(.check_id) | index("reflection-actions-clear")) != null) and
  ((.gates.required_checks | map(.check_id) | index("protocol-chain-complete")) != null) and
  ((.gates.required_checks | map(.check_id) | index("shell-contract-valid")) != null) and
  ((.gates.required_checks | map(.check_id) | index("collaboration-trace-present")) != null) and
  ((.gates.required_checks | map(.check_id) | index("revenue-readiness-minimum")) != null) and
  ((.gates.required_checks | map(.check_id) | index("customer-contract-valid")) != null) and
  ((.gates.required_checks | map(.check_id) | index("audit-bundle-exportable")) != null) and
  ((.gates.required_checks | map(.check_id) | index("incident-exception-governed")) != null) and
  ((.gates.required_checks | map(.check_id) | index("support-ops-ready")) != null) and
  ((.gates.required_checks | map(.check_id) | index("billing-readiness-minimum")) != null) and
  ((.anti_patterns | map(test("expired")) | any)) and
  ((.anti_patterns | map(test("reflection debt")) | any)) and
  ((.anti_patterns | map(test("audit bundle")) | any))
'

validate_jq_contract "control/registry/version-promotion.v0.7.json" "schemas/version_promotion_policy.schema.json" '
  .version=="v0.7" and
  ((.gates.required_all | map(.gate_id) | index("policy-bundle-reproducible")) != null) and
  ((.gates.required_all | map(.gate_id) | index("approval-audit-trail")) != null) and
  ((.gates.required_all | map(.gate_id) | index("revenue-evidence-present")) != null) and
  ((.gates.required_all | map(.gate_id) | index("repeatable-value-unit")) != null) and
  ((.gates.required_all | map(.gate_id) | index("operator-business-dependence")) != null) and
  ((.gates.required_all | map(.gate_id) | index("protocol-audit-complete")) != null) and
  ((.gates.required_all | map(.gate_id) | index("customer-audit-pack-replayable")) != null) and
  ((.gates.required_all | map(.gate_id) | index("incident-postmortem-discipline")) != null) and
  ((.gates.required_all | map(.gate_id) | index("support-sla-proven")) != null) and
  ((.gates.required_all | map(.gate_id) | index("billing-readiness-proven")) != null) and
  ((.gates.required_metrics | map(.metric_id) | index("audit-coverage-ratio")) != null)
'

validate_jq_contract "packs/service-bootstrap/manifest.json" "schemas/trace_record.schema.json" '
  .pack_id=="service-bootstrap" and
  .version=="v0.7" and
  .entry_script=="install.sh" and
  .payload_file=="payload.json"
'

validate_jq_contract "packs/service-bootstrap/payload.json" "schemas/trace_record.schema.json" '
  (.directories|type=="array" and length==9) and
  (.files|type=="array" and length==21) and
  ((.directories | index("governance/policies")) != null) and
  ((.directories | index("orchestration")) != null) and
  ((.directories | index("prompts")) != null) and
  ((.files | map(.path) | index("governance/VERSION")) != null) and
  ((.files | map(.path) | index("orchestration/architecture.blueprint.yaml")) != null) and
  ((.files | map(.path) | index("orchestration/shell.contract.json")) != null) and
  ((.files | map(.path) | index("prompts/agent-system.md")) != null) and
  ((.files | map(.path) | index("prompts/collaboration-ideation.md")) != null)
'

validate_jq_contract "packs/link-kit/manifest.json" "schemas/trace_record.schema.json" '
  .pack_id=="link-kit" and
  .version=="v0.7" and
  .entry_script=="install.sh" and
  .active_link_root=="governance/links/active/<link-id>"
'

validate_jq_contract "packs/audit-bundle/manifest.json" "schemas/trace_record.schema.json" '
  .pack_id=="audit-bundle" and
  .version=="v0.7" and
  .entry_script=="render.sh" and
  .template_file=="bundle.template.json"
'

validate_jq_contract "packs/audit-bundle/bundle.template.json" "schemas/trace_record.schema.json" '
  (.bundle_id|type=="string" and length > 0) and
  (.customer_id|type=="string" and length > 0) and
  (.service_id|type=="string" and length > 0) and
  (.link_id|type=="string" and length > 0) and
  (.auth_contract_ref|type=="string" and length > 0) and
  (.approval_receipt_ref|type=="string" and length > 0) and
  (.baseline_summary_ref|type=="string" and length > 0) and
  (.release_verdict_ref|type=="string" and length > 0) and
  (.reflection_summary_ref|type=="string" and length > 0) and
  (.policy_bundle_refs|type=="array" and length > 0) and
  (.protocol_chain_refs|type=="array" and length > 0) and
  .export_format=="json-bundle"
'

if (( errors > 0 )); then
  exit 1
fi

echo "VALIDATION_PASS"
