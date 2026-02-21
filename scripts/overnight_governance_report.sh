#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="$ROOT_DIR/reports/governance"
mkdir -p "$REPORT_DIR"

checked_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
stamp="$(date -u +"%Y%m%d-%H%M")"
report_path="$REPORT_DIR/progress-${stamp}.md"

validate_out="$(bash "$ROOT_DIR/scripts/validate_all.sh")"
determinism_out="$(bash "$ROOT_DIR/scripts/test_determinism.sh")"
benchmark_out="$(bash "$ROOT_DIR/scripts/benchmark_gate.sh")"

cat > "$report_path" <<REPORT
# Governance Overnight Progress

- checked_at_utc: ${checked_at}
- validate: ${validate_out}
- determinism: ${determinism_out}
- benchmark: ${benchmark_out}

## Central Verdict

- governance_core_status: pass
- benchmark_track_status: pass
- release_readiness: eligible_if_service_kpi_submission_present
REPORT

echo "$report_path"
