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

json_ready() {
  local rel_path="$1"
  [[ -f "$ROOT_DIR/$rel_path" ]] && jq -e . "$ROOT_DIR/$rel_path" >/dev/null 2>&1
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

require jq

bash "$ROOT_DIR/scripts/scan_repo_hygiene.sh"

check_sha256_baseline() {
  local rel_path="$1"
  local line
  local expected_hash
  local target_path
  local actual_hash
  local rel_target

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
      rel_target="$target_path"
      fail "$rel_path" "hash drift for $rel_target"
    fi
  done < "$ROOT_DIR/$rel_path"
}

check_sha256_baseline "docs/baseline.v0.6.sha256"

check_exact_files_in_dir "scripts" \
  "scan_repo_hygiene.sh" \
  "trace_append.sh" \
  "validate_all.sh"

check_exact_files_in_dir ".github/workflows" \
  "deterministic-governance.yml" \
  "github-pages-showcase.yml"

check_file "LICENSE"
check_file "CONTRIBUTING.md"
check_file "SECURITY.md"

for schema_rel in \
  schemas/department_flow.schema.json \
  schemas/launch_readiness.schema.json \
  schemas/link_scan_points.schema.json \
  schemas/mcp_contract_bundle.schema.json \
  schemas/mcp_manifest.schema.json \
  schemas/mcp_runtime_binding.schema.json \
  schemas/mcps_registry.schema.json \
  schemas/service_diet.schema.json \
  schemas/service_kernel.schema.json \
  schemas/service_normalization.schema.json \
  schemas/trace_record.schema.json \
  schemas/trace_rules.schema.json \
  schemas/version_promotion_policy.schema.json
do
  check_json "$schema_rel"
done

for policy_rel in \
  policies/mcp_execution_boundary.v0.6.json
do
  check_json "$policy_rel"
done

for governance_rel in \
  control/agents/departments.v0.6.json \
  control/agents/role.catalog.v0.6.json \
  control/specs/trace_rules.v0.6.json \
  control/registry/department-flow.v0.6.json \
  control/registry/launch-readiness.v0.6.json \
  control/registry/link-scan-points.v0.6.json \
  control/registry/linked-services.v0.6.json \
  control/registry/mcps.v0.6.json \
  control/registry/service-diet.v0.6.json \
  control/registry/service-kernel.v0.6.json \
  control/registry/service-normalization.v0.6.json \
  control/registry/temporary-links.v0.6.json \
  control/registry/version-promotion.v0.6.json
do
  check_json "$governance_rel"
done

check_exact_files_in_dir "control/specs" \
  "trace_rules.v0.6.json"

if json_ready "control/registry/mcps.v0.6.json"; then
  while IFS= read -r root_path; do
    check_allowed_entries_in_dir "$root_path" "manifest.json" "contract.bundle.v0.1.json" "versions"
    check_exact_files_in_dir "$root_path/versions" "runtime.binding.v0.1.json"
  done < <(jq -r '.mcps[].root_path' "$ROOT_DIR/control/registry/mcps.v0.6.json")
fi

validate_jq_contract "control/specs/trace_rules.v0.6.json" "schemas/trace_rules.schema.json" '
  .version=="v0.6" and
  (.append_only==true) and
  (.hash_reference_required==true) and
  (.retention_model.primary_store=="service-local-governance/dtp/") and
  (.retention_model.export_path=="service-local-governance/dtp/journal-exports/") and
  (.dtp.root_path=="governance/dtp/") and
  (.dtp.required_paths|type=="array" and length==3) and
  ((.dtp.required_paths | index("governance/dtp/trace.jsonl")) != null) and
  ((.dtp.required_paths | index("governance/dtp/journal.index.json")) != null) and
  ((.dtp.required_paths | index("governance/dtp/validator.receipt.json")) != null) and
  (.dtp.fixed_genesis_prev_hash=="0000000000000000000000000000000000000000000000000000000000000000") and
  (.journal_export_boundary.mcp_id=="core-governance-journal-mcp") and
  (.journal_export_boundary.target_service=="external-governance-diary")
'

validate_jq_contract "control/registry/department-flow.v0.6.json" "schemas/department_flow.schema.json" '
  .version=="v0.6" and
  (.model=="department-handoff-graph") and
  (.terminal_states | type=="array" and length==1) and
  ((.terminal_states | index("released")) != null) and
  (.max_same_department_reentries_before_human_approval==2) and
  (.allowed_transitions | type=="array" and length==10) and
  (.forbidden_shortcuts | type=="array" and length==3)
'

validate_jq_contract "control/registry/service-kernel.v0.6.json" "schemas/service_kernel.schema.json" '
  .version=="v0.6" and
  (.model=="linked-service-kernel") and
  (.required_root_entries | type=="array" and length==4) and
  (.required_governance_entries | type=="array" and length==8) and
  ((.required_governance_entries | map(.path) | index("governance/dtp")) != null) and
  ((.required_governance_entries | map(.path) | index("governance/dtp/trace.jsonl")) != null) and
  ((.required_governance_entries | map(.path) | index("governance/dtp/journal.index.json")) != null) and
  ((.required_governance_entries | map(.path) | index("governance/dtp/validator.receipt.json")) != null) and
  ((.required_governance_entries | map(.path) | index("governance/links/active")) != null) and
  (.optional_root_entries | type=="array" and length==10) and
  (.profiles | type=="array" and length==3)
'

if check_json "control/registry/temporary-links.v0.6.json"; then
  if ! jq -e '
    .version=="v0.6" and
    (.link_contract.phases | type=="array" and length==5) and
    (.link_contract.completion_rule.missing_scan_status=="incomplete") and
    (.link_contract.completion_rule.production_requires_scan=="pre-release-scan") and
    (.link_contract.residue_policy.link_residue_check_must_be=="none") and
    (.link_contract.residue_policy.incomplete_blocks_release==true) and
    (.link_contract.kit_structure.active_root=="governance/links/active/<link-id>") and
    (.link_contract.kit_structure.required_files | type=="array" and length==9) and
    ((.link_contract.kit_structure.production_extra_files | index("scan.pre-release.json")) != null) and
    (.link_contract.kit_structure.allow_extra_root_level_files==false) and
    (.link_contract.kit_structure.mutable_files == ["status.json"]) and
    (.link_contract.kit_structure.status_required_fields | type=="array" and length==8)
  ' "$ROOT_DIR/control/registry/temporary-links.v0.6.json" >/dev/null 2>&1; then
    fail "control/registry/temporary-links.v0.6.json" "schema validation failed (inline v0.6 temporary-link rules)"
  fi
fi

validate_jq_contract "control/registry/launch-readiness.v0.6.json" "schemas/launch_readiness.schema.json" '
  .version=="v0.6" and
  (.policy_id=="launch-readiness") and
  (.gates.required_all|type=="array" and length>=4) and
  (.gates.required_checks|type=="array" and length>=4) and
  ((.gates.required_checks | map(.check_id) | index("dtp-current")) != null) and
  (.promotion_effect.blocks_v1_without_version_promotion==true)
'

validate_jq_contract "control/registry/service-normalization.v0.6.json" "schemas/service_normalization.schema.json" '
  .version=="v0.6" and
  (.model=="one-time-service-normalization") and
  (.required_phases|type=="array" and length==4) and
  (.completion_rule.required_status=="normalized") and
  (.status_rules.normalized_when_all|type=="array" and length>=6)
'

validate_jq_contract "control/registry/service-diet.v0.6.json" "schemas/service_diet.schema.json" '
  .version=="v0.6" and
  (.model=="linked-service-diet") and
  (.status_levels|type=="array" and length==4) and
  (.classification_rules.retain_if_any|type=="array" and length>=6) and
  (.classification_rules.archive_if_all|type=="array" and length>=6) and
  (.classification_rules.forbidden_if_any|type=="array" and length>=4) and
  (.completion_rule.required_status=="diet-scanned-light")
'

if json_ready "control/agents/departments.v0.6.json" && json_ready "control/agents/role.catalog.v0.6.json"; then
  if ! jq -n \
    --slurpfile departments "$ROOT_DIR/control/agents/departments.v0.6.json" \
    --slurpfile roles "$ROOT_DIR/control/agents/role.catalog.v0.6.json" '
      ($departments[0].departments | map(.id)) as $dept_ids |
      all($roles[0].roles[];
        . as $role |
        ($dept_ids | index($role.home_department)) != null and
        ($role.allowed_departments | all(.[]; . as $allowed | ($dept_ids | index($allowed)) != null))
      )
    ' >/dev/null 2>&1; then
    fail "control/agents/role.catalog.v0.6.json" "role departments must resolve against departments.v0.6.json"
  fi
fi

if json_ready "control/registry/service-kernel.v0.6.json" && json_ready "control/registry/linked-services.v0.6.json"; then
  if ! jq -n \
    --slurpfile kernel "$ROOT_DIR/control/registry/service-kernel.v0.6.json" \
    --slurpfile services "$ROOT_DIR/control/registry/linked-services.v0.6.json" '
      ($kernel[0].profiles | map(.profile_id)) as $profile_ids |
      all($services[0].services[];
        . as $service |
        ($profile_ids | index($service.service_root_profile)) != null and
        ($service.service_contract_ref == "governance/service.contract.json")
      )
    ' >/dev/null 2>&1; then
    fail "control/registry/linked-services.v0.6.json" "linked service profiles must resolve against service-kernel.v0.6.json"
  fi
fi

if json_ready "control/specs/trace_rules.v0.6.json" && json_ready "control/registry/service-kernel.v0.6.json"; then
  if ! jq -n \
    --slurpfile trace "$ROOT_DIR/control/specs/trace_rules.v0.6.json" \
    --slurpfile kernel "$ROOT_DIR/control/registry/service-kernel.v0.6.json" '
      ($trace[0].dtp.required_paths) as $required_paths |
      ($kernel[0].required_governance_entries | map(.path)) as $kernel_paths |
      all($required_paths[]; $kernel_paths | index(.) != null)
    ' >/dev/null 2>&1; then
    fail "control/registry/service-kernel.v0.6.json" "service kernel must embed the DTP required paths declared by trace_rules.v0.6.json"
  fi
fi

if [[ -d "$ROOT_DIR/control/mcps" ]] && json_ready "control/registry/mcps.v0.6.json"; then
  if ! jq -n \
    --slurpfile registry "$ROOT_DIR/control/registry/mcps.v0.6.json" '
      ($registry[0].mcps | map(.root_path | split("/") | last) | sort) as $expected |
      $expected == $expected
    ' >/dev/null 2>&1; then
    fail "control/registry/mcps.v0.6.json" "mcp registry shape invalid"
  fi

  while IFS= read -r dir_path; do
    dir_name="$(basename "$dir_path")"
    if ! jq -e --arg name "$dir_name" '.mcps | any(.root_path == ("control/mcps/" + $name))' \
      "$ROOT_DIR/control/registry/mcps.v0.6.json" >/dev/null 2>&1; then
      fail "control/mcps/$dir_name" "directory not registered in mcps.v0.6.json"
    fi
  done < <(find "$ROOT_DIR/control/mcps" -mindepth 1 -maxdepth 1 -type d | sort)
fi

check_file "docs/index.html"
check_file "docs/assets/site.css"
check_file "docs/assets/site.js"
check_file "docs/.nojekyll"

if (( errors > 0 )); then
  exit 1
fi

echo "VALIDATION_PASS"
