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
- classify cleanup candidates
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

bootstrap_kernel() {
  ensure_dir governance/dtp
  ensure_dir governance/links/active
  ensure_dir governance/evidence
  ensure_dir governance/reviews
  ensure_dir governance/monitoring
  ensure_dir orchestration
  ensure_dir prompts
  ensure_dir tools

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

write_snapshot() {
  local tree_hash
  local current_trace_head

  tree_hash="$(hash_tree)"
  current_trace_head="$(trace_head)"

  cat > governance/monitoring/service.snapshot.json <<EOF
{
  "version": "v0.7",
  "service_id": "${SERVICE_ID}",
  "service_root_profile": "${SERVICE_PROFILE}",
  "snapshot_id": "${tree_hash}",
  "tree_hash": "${tree_hash}",
  "trace_head": "${current_trace_head}",
  "present_paths": [],
  "protected_paths": [],
  "large_directories": [],
  "duplicate_surfaces": [],
  "stale_surfaces": [],
  "runtime_tooling": [],
  "orchestration_surface_status": "present",
  "prompt_pack_status": "present"
}
EOF
}

write_hygiene() {
  local snapshot_id
  snapshot_id="$(jq -r '.snapshot_id' governance/monitoring/service.snapshot.json)"

  cat > governance/monitoring/hygiene.report.json <<EOF
{
  "version": "v0.7",
  "service_id": "${SERVICE_ID}",
  "snapshot_id": "${snapshot_id}",
  "status": "healthy",
  "archive_candidates": [],
  "delete_review_candidates": [],
  "keep_paths": [],
  "risk_flags": [],
  "recommended_action": "none",
  "receipt_ref": "local://governance/monitoring/hygiene.report.json"
}
EOF
}

case "$MODE" in
  bootstrap)
    bootstrap_kernel
    write_snapshot
    write_hygiene
    ;;
  scan|sync)
    write_snapshot
    write_hygiene
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
```

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
- Bias `archive_candidates` toward stale demos, old exports, and dead wrappers

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
- Treat stale batch outputs, duplicated job handlers, and oversized logs as primary hygiene risks

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
- cleanup rules for archive and delete-review candidates

The structure and output format should remain the same.

## Safe Defaults

These rules should remain consistent across services:

- `bootstrap` may create missing directories and missing minimum files
- `scan` may refresh monitoring artifacts
- `sync` may send validated artifacts to an external API boundary
- deletion should stay off by default
- cleanup should be split into explicit modes such as:
  - `apply-safe-fixes`
  - `apply-archive`
  - `apply-cleanup`

## Session Rule

When starting a new agent session inside a linked service, the first command should be:

```bash
bash tools/governance_link.sh "$(pwd)" scan
```

If the service has not been aligned yet, start with:

```bash
bash tools/governance_link.sh "$(pwd)" bootstrap
```

## Why This Stays In `docs/`

This repository keeps the bootstrap source in `docs/` because:

- central governance defines the protocol
- each service owns the actual runtime file
- the central repository stays a contract kernel, not a template generator

So this file is the canonical reference, while each service keeps its own `tools/governance_link.sh`.
