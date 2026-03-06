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
  "launch-readiness.v0.7.json" \
  "link-approval-receipt.v0.7.json" \
  "link-auth-contract.v0.7.json" \
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

check_exact_files_in_dir "schemas" \
  "launch_readiness.schema.json" \
  "link_approval_receipt.schema.json" \
  "link_auth_contract.schema.json" \
  "link_scan_points.schema.json" \
  "reflection_packet.schema.json" \
  "service_kernel.schema.json" \
  "trace_record.schema.json" \
  "trace_rules.schema.json" \
  "version_promotion_policy.schema.json"

for schema_rel in \
  schemas/launch_readiness.schema.json \
  schemas/link_approval_receipt.schema.json \
  schemas/link_auth_contract.schema.json \
  schemas/link_scan_points.schema.json \
  schemas/reflection_packet.schema.json \
  schemas/service_kernel.schema.json \
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

for governance_rel in \
  control/specs/trace_rules.v0.7.json \
  control/registry/launch-readiness.v0.7.json \
  control/registry/link-approval-receipt.v0.7.json \
  control/registry/link-auth-contract.v0.7.json \
  control/registry/link-scan-points.v0.7.json \
  control/registry/service-diet.v0.7.json \
  control/registry/service-kernel.v0.7.json \
  control/registry/service-normalization.v0.7.json \
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
  (.allowed_record_types|type=="array" and length==5) and
  ((.allowed_record_types | index("reflection_packet")) != null) and
  (.retention_model.primary_store=="service-local-governance/dtp/") and
  (.retention_model.export_path=="service-local-governance/dtp/api-sync/") and
  (.dtp.root_path=="governance/dtp/") and
  (.dtp.required_paths|type=="array" and length==3) and
  (.reflection_gate.required_fields|type=="array" and length==8) and
  ((.reflection_gate.required_fields | index("problem_statement")) != null) and
  ((.reflection_gate.required_fields | index("evidence_refs")) != null) and
  ((.reflection_gate.required_fields | index("root_cause_chain")) != null) and
  ((.reflection_gate.required_fields | index("fix_action")) != null) and
  ((.reflection_gate.required_fields | index("owner")) != null) and
  ((.reflection_gate.required_fields | index("due_date_ref")) != null) and
  ((.reflection_gate.required_fields | index("severity")) != null) and
  ((.reflection_gate.required_fields | index("status")) != null) and
  (.telemetry_sync_boundary.transport=="http-api") and
  (.telemetry_sync_boundary.ownership=="service-local")
'

validate_jq_contract "control/registry/service-kernel.v0.7.json" "schemas/service_kernel.schema.json" '
  .version=="v0.7" and
  (.required_root_entries|length==6) and
  (.required_governance_entries|length==15) and
  (.required_orchestration_entries|length==4) and
  (.required_prompt_entries|length==5) and
  ((.rules | map(test("governance/ surface only")) | any)) and
  ((.rules | map(test("Whole-repository read scans")) | any)) and
  ((.rules | map(test("auth.contract.json")) | any)) and
  ((.required_governance_entries | map(.path) | index("governance/VERSION")) != null) and
  ((.required_governance_entries | map(.path) | index("governance/plan.json")) != null) and
  ((.required_governance_entries | map(.path) | index("governance/monitoring/service.snapshot.json")) != null) and
  ((.required_governance_entries | map(.path) | index("governance/monitoring/hygiene.report.json")) != null)
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
  ((.anti_patterns | map(test("expired")) | any)) and
  ((.anti_patterns | map(test("reflection debt")) | any))
'

validate_jq_contract "control/registry/version-promotion.v0.7.json" "schemas/version_promotion_policy.schema.json" '
  .version=="v0.7" and
  ((.gates.required_all | map(.gate_id) | index("policy-bundle-reproducible")) != null) and
  ((.gates.required_all | map(.gate_id) | index("approval-audit-trail")) != null) and
  ((.gates.required_metrics | map(.metric_id) | index("audit-coverage-ratio")) != null)
'

if (( errors > 0 )); then
  exit 1
fi

echo "VALIDATION_PASS"
