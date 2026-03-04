# Service Bootstrap For Linked Services

This document is the central reference for bootstrapping a linked service under `ai-governance v0.7`.

The central repository does not own service-local runtime files.
It does provide the base bootstrap pattern that each service can copy and adapt.

## Fixed Rule

Every linked service should place the local entrypoint at:

`tools/governance_link.sh`

That file is the service-local command used to:

- bootstrap the minimum governance-facing surface
- scan the current structure
- generate monitoring artifacts
- classify archive and delete-review candidates
- apply safe fixes
- move archive-safe surfaces into a local archive path
- stage cleanup-review packets without auto-deleting runtime files
- optionally sync receipts to an external API boundary

## Base Template

Use this as the starting point for every service.

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(pwd)}"
MODE="${2:-scan}"

cd "$ROOT"

SERVICE_ID="${SERVICE_ID:-$(basename "$ROOT")}"
SERVICE_PROFILE="${SERVICE_PROFILE:-web-runtime}"
ARCHIVE_ROOT="${ARCHIVE_ROOT:-.archive/governance-diet}"
CLEANUP_REVIEW_ROOT="${CLEANUP_REVIEW_ROOT:-governance/reviews/cleanup-review}"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing command: $1" >&2
    exit 1
  }
}

ensure_dir() {
  mkdir -p "$1"
}

ensure_file() {
  local path="$1"
  local content="$2"
  if [[ ! -e "$path" ]]; then
    printf '%s\n' "$content" > "$path"
  fi
}

json_array() {
  local values=("$@")
  printf '%s\n' "${values[@]}" | jq -R . | jq -s .
}

hash_tree() {
  if command -v sha256sum >/dev/null 2>&1; then
    find . -type f ! -path './.git/*' | sort | sha256sum | awk '{print $1}'
  else
    find . -type f ! -path './.git/*' | sort | shasum -a 256 | awk '{print $1}'
  fi
}

trace_head() {
  if [[ -f governance/dtp/trace.jsonl ]]; then
    tail -n 1 governance/dtp/trace.jsonl | jq -r '.record_hash // "none"' 2>/dev/null || echo "none"
  else
    echo "none"
  fi
}

runtime_tooling_by_profile() {
  case "$SERVICE_PROFILE" in
    web-runtime) printf '%s\n' "browser-automation" "ui-build" ;;
    tool-runtime) printf '%s\n' "cli-wrapper" "api-client" ;;
    worker-runtime) printf '%s\n' "queue-worker" "batch-runner" ;;
    *) printf '%s\n' ;;
  esac
}

protected_paths_by_profile() {
  case "$SERVICE_PROFILE" in
    web-runtime) printf '%s\n' "app" "src" "public" "governance" "orchestration" "prompts" "tools" ;;
    tool-runtime) printf '%s\n' "src" "bin" "tools" "governance" "orchestration" "prompts" ;;
    worker-runtime) printf '%s\n' "workers" "jobs" "ops" "governance" "orchestration" "prompts" ;;
    *) printf '%s\n' "governance" "orchestration" "prompts" "tools" ;;
  esac
}

bootstrap_kernel() {
  ensure_dir governance/dtp
  ensure_dir governance/links/active
  ensure_dir governance/evidence
  ensure_dir governance/reviews
  ensure_dir governance/monitoring
  ensure_dir orchestration
  ensure_dir prompts
  ensure_dir tools
  ensure_dir "$ARCHIVE_ROOT"
  ensure_dir "$CLEANUP_REVIEW_ROOT"

  ensure_file README.md "# ${SERVICE_ID}"
  ensure_file service.yaml "service_id: ${SERVICE_ID}\nservice_root_profile: ${SERVICE_PROFILE}"
  ensure_file .gitignore ".DS_Store"

  ensure_file governance/service.contract.json "{\n  \"service_id\": \"${SERVICE_ID}\",\n  \"version\": \"v0.7\"\n}"
  ensure_file governance/dtp/trace.jsonl ""
  ensure_file governance/dtp/journal.index.json "{\n  \"trace_path\": \"governance/dtp/trace.jsonl\",\n  \"trace_head\": \"none\",\n  \"record_count\": 0,\n  \"append_only\": true,\n  \"hash_algorithm\": \"sha256\",\n  \"last_validated_by\": \"none\",\n  \"last_validated_at_ref\": \"none\"\n}"
  ensure_file governance/dtp/validator.receipt.json "{\n  \"trace_path\": \"governance/dtp/trace.jsonl\",\n  \"validated_trace_head\": \"none\",\n  \"validated_record_count\": 0,\n  \"schema_ref\": \"schemas/trace_record.schema.json\",\n  \"trace_rules_ref\": \"control/specs/trace_rules.v0.7.json\",\n  \"verdict\": \"pass\",\n  \"failures\": [],\n  \"receipt_hash\": \"none\"\n}"

  ensure_file orchestration/service.map.yaml "service_id: ${SERVICE_ID}\nservice_root_profile: ${SERVICE_PROFILE}\nprimary_owner_role: architect-owner\nassigned_roles:\n  - architect-owner\n  - product-strategist\n  - service-builder\n  - qa-reviewer\n  - release-review"
  ensure_file orchestration/stack.profile.yaml "service_root_profile: ${SERVICE_PROFILE}\nlanguages:\n  - json\n  - yaml\n  - sh"
  ensure_file orchestration/package-policy.yaml "preferred: []\nallowed: []\navoid: []\nforbidden: []"
  ensure_file orchestration/execution.plan.md "# Execution Plan"

  ensure_file prompts/ideation.md "# Ideation"
  ensure_file prompts/macro-planning.md "# Macro Planning"
  ensure_file prompts/tech-selection.md "# Tech Selection"
  ensure_file prompts/implementation-kickoff.md "# Implementation Kickoff"
  ensure_file prompts/review-recovery.md "# Review Recovery"
}

collect_present_paths() {
  find . -mindepth 1 -maxdepth 2 \
    ! -path './.git*' \
    ! -path './node_modules*' \
    | sed 's#^\./##' \
    | sort
}

collect_large_directories() {
  local output=()
  while IFS= read -r line; do
    output+=("$line")
  done < <(find . -mindepth 1 -maxdepth 2 -type d ! -path './.git*' ! -path './node_modules*' \
    -exec du -sk {} + 2>/dev/null \
    | awk '$1 >= 20480 {print $2}' \
    | sed 's#^\./##' \
    | sort)
  printf '%s\n' "${output[@]}"
}

collect_archive_candidates() {
  local output=()
  local candidate
  for candidate in \
    ".next" "dist" "build" "coverage" ".turbo" ".cache" "tmp" "temp" "logs" \
    "storybook-static" "playwright-report"
  do
    if [[ -e "$candidate" ]]; then
      output+=("$candidate")
    fi
  done
  printf '%s\n' "${output[@]}"
}

collect_delete_review_candidates() {
  local output=()
  local path
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    case "$path" in
      governance/*|orchestration/*|prompts/*|tools/*|README.md|service.yaml|.gitignore)
        ;;
      *.bak|*.old|*.orig|*.rej)
        output+=("$path")
        ;;
    esac
  done < <(find . -type f ! -path './.git/*' | sed 's#^\./##' | sort)
  printf '%s\n' "${output[@]}"
}

collect_stale_surfaces() {
  local output=()
  local candidate
  for candidate in \
    "docs/tmp" "docs/cache" "tmp" "temp" ".eslintcache" ".parcel-cache"
  do
    if [[ -e "$candidate" ]]; then
      output+=("$candidate")
    fi
  done
  printf '%s\n' "${output[@]}"
}

contains_line() {
  local needle="$1"
  shift
  local value
  for value in "$@"; do
    if [[ "$value" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

write_snapshot() {
  local tree_hash current_trace_head
  mapfile -t present_paths < <(collect_present_paths)
  mapfile -t protected_paths < <(protected_paths_by_profile)
  mapfile -t large_directories < <(collect_large_directories)
  mapfile -t stale_surfaces < <(collect_stale_surfaces)
  mapfile -t runtime_tooling < <(runtime_tooling_by_profile)

  tree_hash="$(hash_tree)"
  current_trace_head="$(trace_head)"

  jq -n \
    --arg service_id "$SERVICE_ID" \
    --arg service_root_profile "$SERVICE_PROFILE" \
    --arg snapshot_id "$tree_hash" \
    --arg tree_hash "$tree_hash" \
    --arg trace_head "$current_trace_head" \
    --argjson present_paths "$(json_array "${present_paths[@]}")" \
    --argjson protected_paths "$(json_array "${protected_paths[@]}")" \
    --argjson large_directories "$(json_array "${large_directories[@]}")" \
    --argjson duplicate_surfaces "[]" \
    --argjson stale_surfaces "$(json_array "${stale_surfaces[@]}")" \
    --argjson runtime_tooling "$(json_array "${runtime_tooling[@]}")" \
    '{
      version: "v0.7",
      service_id: $service_id,
      service_root_profile: $service_root_profile,
      snapshot_id: $snapshot_id,
      tree_hash: $tree_hash,
      trace_head: $trace_head,
      present_paths: $present_paths,
      protected_paths: $protected_paths,
      large_directories: $large_directories,
      duplicate_surfaces: $duplicate_surfaces,
      stale_surfaces: $stale_surfaces,
      runtime_tooling: $runtime_tooling,
      orchestration_surface_status: "present",
      prompt_pack_status: "present"
    }' > governance/monitoring/service.snapshot.json
}

write_hygiene() {
  local snapshot_id status action
  mapfile -t archive_candidates < <(collect_archive_candidates)
  mapfile -t delete_review_candidates < <(collect_delete_review_candidates)
  mapfile -t protected_paths < <(protected_paths_by_profile)

  status="healthy"
  action="none"

  if (( ${#archive_candidates[@]} > 0 )) || (( ${#delete_review_candidates[@]} > 0 )); then
    status="attention"
    action="review-cleanup-candidates"
  fi

  if (( ${#delete_review_candidates[@]} > 6 )); then
    status="cleanup-required"
    action="human-cleanup-review-required"
  fi

  snapshot_id="$(jq -r '.snapshot_id' governance/monitoring/service.snapshot.json)"

  jq -n \
    --arg service_id "$SERVICE_ID" \
    --arg snapshot_id "$snapshot_id" \
    --arg status "$status" \
    --arg recommended_action "$action" \
    --arg receipt_ref "local://governance/monitoring/hygiene.report.json" \
    --argjson archive_candidates "$(json_array "${archive_candidates[@]}")" \
    --argjson delete_review_candidates "$(json_array "${delete_review_candidates[@]}")" \
    --argjson keep_paths "$(json_array "${protected_paths[@]}")" \
    --argjson risk_flags "$(json_array "$status")" \
    '{
      version: "v0.7",
      service_id: $service_id,
      snapshot_id: $snapshot_id,
      status: $status,
      archive_candidates: $archive_candidates,
      delete_review_candidates: $delete_review_candidates,
      keep_paths: $keep_paths,
      risk_flags: $risk_flags,
      recommended_action: $recommended_action,
      receipt_ref: $receipt_ref
    }' > governance/monitoring/hygiene.report.json
}

write_cleanup_receipt() {
  local action="$1"
  local now_ref
  now_ref="$(date -u +%Y%m%dT%H%M%SZ)"

  jq -n \
    --arg service_id "$SERVICE_ID" \
    --arg action "$action" \
    --arg now_ref "$now_ref" \
    '{
      version: "v0.7",
      service_id: $service_id,
      action: $action,
      receipt_ref: ("local://governance/evidence/" + $action + "." + $now_ref + ".json"),
      generated_at_ref: $now_ref
    }' > "governance/evidence/${action}.${now_ref}.json"
}

apply_safe_fixes() {
  bootstrap_kernel
  write_snapshot
  write_hygiene
  write_cleanup_receipt "apply-safe-fixes"
}

apply_archive() {
  local candidate
  mapfile -t archive_candidates < <(jq -r '.archive_candidates[]?' governance/monitoring/hygiene.report.json)

  ensure_dir "$ARCHIVE_ROOT"
  for candidate in "${archive_candidates[@]}"; do
    [[ -e "$candidate" ]] || continue
    mv "$candidate" "$ARCHIVE_ROOT/"
  done

  write_snapshot
  write_hygiene
  write_cleanup_receipt "apply-archive"
}

apply_cleanup_review() {
  local target
  mapfile -t delete_review_candidates < <(jq -r '.delete_review_candidates[]?' governance/monitoring/hygiene.report.json)

  ensure_dir "$CLEANUP_REVIEW_ROOT"
  printf '# Cleanup Review\\n\\n' > "$CLEANUP_REVIEW_ROOT/pending.md"
  for target in "${delete_review_candidates[@]}"; do
    printf -- '- %s\\n' "$target" >> "$CLEANUP_REVIEW_ROOT/pending.md"
  done

  write_cleanup_receipt "apply-cleanup-review"
}

sync_artifacts() {
  write_cleanup_receipt "sync"
  echo "Sync placeholder: POST validated monitoring artifacts to the service-owned API boundary."
}

require_cmd jq

case "$MODE" in
  bootstrap)
    bootstrap_kernel
    write_snapshot
    write_hygiene
    ;;
  scan)
    write_snapshot
    write_hygiene
    ;;
  apply-safe-fixes)
    apply_safe_fixes
    ;;
  apply-archive)
    write_snapshot
    write_hygiene
    apply_archive
    ;;
  apply-cleanup-review)
    write_snapshot
    write_hygiene
    apply_cleanup_review
    ;;
  sync)
    write_snapshot
    write_hygiene
    sync_artifacts
    ;;
  *)
    echo "Unsupported mode: $MODE" >&2
    exit 1
    ;;
esac

echo "service_id=${SERVICE_ID}"
echo "service_root_profile=${SERVICE_PROFILE}"
echo "mode=${MODE}"
echo "monitoring_status=$(jq -r '.status' governance/monitoring/hygiene.report.json)"
echo "archive_candidates=$(jq -r '.archive_candidates | length' governance/monitoring/hygiene.report.json)"
echo "delete_review_candidates=$(jq -r '.delete_review_candidates | length' governance/monitoring/hygiene.report.json)"
```

## Cleanup Model

The important rule is:

- safe fixes may create and refresh required surfaces
- archive mode may move only clearly disposable generated output
- cleanup review may stage risky candidates for human review
- automatic deletion should still stay off by default

Recommended mode meanings:

- `bootstrap`
  - create missing governance-facing surfaces
- `scan`
  - refresh `service.snapshot.json` and `hygiene.report.json`
- `apply-safe-fixes`
  - create missing required paths and rewrite monitoring artifacts
- `apply-archive`
  - move archive candidates into `.archive/governance-diet/`
- `apply-cleanup-review`
  - write a human review packet for delete-review candidates
- `sync`
  - send validated monitoring artifacts to the service-owned API boundary

## Profile Adjustments

The base template is shared.
These fields should be adjusted per service profile.

### `web-runtime`

Typical changes:

- Set `SERVICE_PROFILE=web-runtime`
- Add `frontend-engineer` to `assigned_roles`
- Add `ux-specialist` and `css-specialist` to `assigned_roles` when the service has meaningful UI
- Add browser tooling under `runtime_tooling`
- Protect UI-critical paths such as:
  - `app/`
  - `src/`
  - `public/`
- Include style and layout surfaces in `stale_surfaces` checks
- Treat generated build folders as the first archive candidates:
  - `.next`
  - `dist`
  - `storybook-static`

Suggested `assigned_roles` baseline:

```yaml
assigned_roles:
  - architect-owner
  - product-strategist
  - service-builder
  - frontend-engineer
  - qa-reviewer
  - release-review
```

### `tool-runtime`

Typical changes:

- Set `SERVICE_PROFILE=tool-runtime`
- Add `backend-engineer` to `assigned_roles`
- Keep `runtime_tooling` focused on CLI or integration helpers
- Protect tool entry paths such as:
  - `src/`
  - `bin/`
  - `tools/`
- Bias `archive_candidates` toward stale demos, exports, wrappers, and generated reports

Suggested `assigned_roles` baseline:

```yaml
assigned_roles:
  - architect-owner
  - product-strategist
  - service-builder
  - backend-engineer
  - qa-reviewer
  - release-review
```

### `worker-runtime`

Typical changes:

- Set `SERVICE_PROFILE=worker-runtime`
- Add `data-automation` to `assigned_roles`
- Add `devops-sre` when queues, schedulers, or background jobs are material
- Protect execution surfaces such as:
  - `workers/`
  - `jobs/`
  - `ops/`
- Treat stale batch outputs, duplicated job handlers, temp directories, and oversized logs as primary hygiene risks

Suggested `assigned_roles` baseline:

```yaml
assigned_roles:
  - architect-owner
  - product-strategist
  - service-builder
  - data-automation
  - qa-reviewer
  - release-review
```

## What May Differ Per Service

These values should be customized for each service:

- `SERVICE_ID`
- `SERVICE_PROFILE`
- `assigned_roles`
- `protected_paths`
- `runtime_tooling`
- external API sync endpoint
- archive candidate heuristics
- delete-review candidate heuristics

The structure and output format should remain the same.

## Safe Defaults

These rules should remain consistent across services:

- `bootstrap` may create missing directories and missing minimum files
- `scan` may refresh monitoring artifacts
- `apply-safe-fixes` may create and rewrite, but not delete
- `apply-archive` may move only disposable generated surfaces
- `apply-cleanup-review` may create review packets, but not delete
- `sync` may send validated artifacts to an external API boundary
- automatic deletion should remain off unless a human explicitly approves a service-local cleanup action

## Session Rule

When starting a new agent session inside a linked service, the first command should be:

```bash
bash tools/governance_link.sh "$(pwd)" scan
```

If the service has not been aligned yet, start with:

```bash
bash tools/governance_link.sh "$(pwd)" bootstrap
```

If the structure is already present but drift is obvious, start with:

```bash
bash tools/governance_link.sh "$(pwd)" apply-safe-fixes
```

## Why This Stays In `docs/`

This repository keeps the bootstrap source in `docs/` because:

- central governance defines the protocol
- each service owns the actual runtime file
- the central repository stays a contract kernel, not a template generator

So this file is the canonical reference, while each service keeps its own `tools/governance_link.sh`.
