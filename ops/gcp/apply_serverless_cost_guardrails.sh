#!/usr/bin/env bash
set -euo pipefail

# Applies cost-first serverless guardrails per project:
# - remove Cloud SQL IAM roles
# - disable sqladmin.googleapis.com
# - set Artifact Registry cleanup policies
# - create/update per-project budgets (50/80/100)
# - create BigQuery dataset targets for billing export
#
# Note: Cloud Billing Export itself is billing-account scoped, not project scoped.
# This script prepares dataset targets and prints a one-click console URL.

if ! command -v gcloud >/dev/null 2>&1; then
  echo "Missing command: gcloud" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Missing command: jq" >&2
  exit 1
fi

if ! command -v bq >/dev/null 2>&1; then
  echo "Missing command: bq" >&2
  exit 1
fi

PROJECTS=("$@")
if [[ ${#PROJECTS[@]} -eq 0 ]]; then
  PROJECTS=("plotnodes-prod" "divine-prod" "kakao-bot-prod")
fi

AR_POLICY_FILE="$(mktemp)"
trap 'rm -f "${AR_POLICY_FILE}"' EXIT

cat > "${AR_POLICY_FILE}" <<'JSON'
[
  {
    "name": "delete-old-images",
    "action": {
      "type": "Delete"
    },
    "condition": {
      "tagState": "any",
      "olderThan": "30d"
    }
  },
  {
    "name": "keep-recent-versions",
    "action": {
      "type": "Keep"
    },
    "mostRecentVersions": {
      "keepCount": 20
    }
  }
]
JSON

project_exists() {
  local project_id="$1"
  gcloud projects describe "${project_id}" --format='value(projectId)' >/dev/null 2>&1
}

project_number() {
  local project_id="$1"
  gcloud projects describe "${project_id}" --format='value(projectNumber)'
}

billing_account_for_project() {
  local project_id="$1"
  gcloud billing projects describe "${project_id}" --format='value(billingAccountName)' | sed 's#^billingAccounts/##'
}

remove_cloudsql_iam_roles() {
  local project_id="$1"
  local tmp_json
  tmp_json="$(mktemp)"
  gcloud projects get-iam-policy "${project_id}" --format=json > "${tmp_json}"

  while IFS=$'\t' read -r role member; do
    [[ -z "${role}" || -z "${member}" ]] && continue
    echo "REMOVE_IAM project=${project_id} role=${role} member=${member}"
    gcloud projects remove-iam-policy-binding "${project_id}" \
      --role "${role}" \
      --member "${member}" \
      --quiet >/dev/null || true
  done < <(jq -r '.bindings[] | select(.role|test("cloudsql")) | .role as $r | .members[] | [$r, .] | @tsv' "${tmp_json}")

  rm -f "${tmp_json}"
}

disable_sqladmin_api() {
  local project_id="$1"
  echo "DISABLE_API project=${project_id} api=sqladmin.googleapis.com"
  gcloud services disable sqladmin.googleapis.com --project "${project_id}" --quiet >/dev/null || true
}

apply_artifact_cleanup_policies() {
  local project_id="$1"
  while IFS=$'\t' read -r full_name format; do
    [[ -z "${full_name}" ]] && continue
    [[ "${format}" != "DOCKER" ]] && continue
    local location repo_name
    location="$(echo "${full_name}" | awk -F'/' '{print $4}')"
    repo_name="$(echo "${full_name}" | awk -F'/' '{print $6}')"
    [[ -z "${repo_name}" || -z "${location}" ]] && continue
    echo "SET_AR_POLICY project=${project_id} repo=${repo_name} location=${location}"
    gcloud artifacts repositories set-cleanup-policies "${repo_name}" \
      --project "${project_id}" \
      --location "${location}" \
      --policy "${AR_POLICY_FILE}" \
      --quiet >/dev/null
  done < <(
    gcloud artifacts repositories list \
      --project "${project_id}" \
      --format='value(name,format)'
  )
}

ensure_budget_alerts() {
  local project_id="$1"
  local billing_account="$2"
  local display_name="cost-guardrail-${project_id}"
  local existing_budget
  existing_budget="$(
    gcloud billing budgets list \
      --billing-account "${billing_account}" \
      --format='value(name,displayName)' \
      | awk -v dn="${display_name}" '$2==dn{print $1; exit}'
  )"

  if [[ -n "${existing_budget}" ]]; then
    echo "RECREATE_BUDGET project=${project_id} budget=${existing_budget}"
    gcloud billing budgets delete "${existing_budget}" --billing-account "${billing_account}" --quiet >/dev/null
  fi

  echo "CREATE_BUDGET project=${project_id}"
  gcloud billing budgets create \
    --billing-account "${billing_account}" \
    --display-name "${display_name}" \
    --last-period-amount \
    --calendar-period month \
    --filter-projects "projects/${project_id}" \
    --threshold-rule percent=0.5,basis=current-spend \
    --threshold-rule percent=0.8,basis=current-spend \
    --threshold-rule percent=1.0,basis=current-spend \
    --quiet >/dev/null
}

ensure_billing_export_dataset() {
  local project_id="$1"
  local dataset_id="billing_export"
  local location="US"
  echo "ENSURE_DATASET project=${project_id} dataset=${dataset_id}"
  bq --project_id="${project_id}" mk --dataset --location="${location}" --description "Cloud Billing export target" "${project_id}:${dataset_id}" >/dev/null 2>&1 || true
}

print_billing_export_notice() {
  local billing_account="$1"
  echo ""
  echo "BILLING_EXPORT_MANUAL_STEP_REQUIRED billing_account=${billing_account}"
  echo "Cloud Billing Export is billing-account scoped."
  echo "Set Detailed usage cost export once at:"
  echo "https://console.cloud.google.com/billing/${billing_account}/reports?project="
  echo "Target dataset suggestion: <project>.billing_export"
  echo ""
}

for project_id in "${PROJECTS[@]}"; do
  echo "=== PROJECT ${project_id} ==="
  if ! project_exists "${project_id}"; then
    echo "SKIP project-not-found ${project_id}"
    continue
  fi

  remove_cloudsql_iam_roles "${project_id}"
  disable_sqladmin_api "${project_id}"
  apply_artifact_cleanup_policies "${project_id}"

  billing_account="$(billing_account_for_project "${project_id}")"
  if [[ -n "${billing_account}" ]]; then
    ensure_budget_alerts "${project_id}" "${billing_account}"
    ensure_billing_export_dataset "${project_id}"
    print_billing_export_notice "${billing_account}"
  else
    echo "SKIP_BUDGET project=${project_id} reason=no-billing-account"
  fi
done

echo "DONE"
