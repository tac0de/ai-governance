#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

STRICT=0
if [[ "${1:-}" == "--strict" ]]; then
  STRICT=1
fi

warn_count=0

section() {
  echo
  echo "== $1 =="
}

warn() {
  warn_count=$((warn_count + 1))
  echo "[WARN] $1"
}

ok() {
  echo "[OK] $1"
}

section "Repo Sweep Summary"
echo "root=${ROOT_DIR}"
echo "mode=$([[ ${STRICT} -eq 1 ]] && echo strict || echo report)"

section "1) Merge conflict markers"
if rg -n "^(<<<<<<< |>>>>>>> )" \
  --glob "!_archive/**" \
  --glob "!_artifacts/**" \
  --glob "!.ops/**" \
  --glob "!.git/**" >/tmp/repo_sweep_conflicts.txt 2>/dev/null; then
  warn "Found unresolved merge markers:"
  cat /tmp/repo_sweep_conflicts.txt
else
  ok "No merge markers found."
fi

section "2) Legacy naming drift (codex)"
scan_targets=(README.md REPOS.md MASTER_CONTEXT.md DECISIONS.md PROJECT_STORY_FOR_HUMANS.md docs tools .github)
if [[ -d scripts ]]; then
  scan_targets+=(scripts)
fi
if rg -n "codex" "${scan_targets[@]}" 2>/tmp/repo_sweep_rg_err.log >/tmp/repo_sweep_codex.txt; then
  echo "[INFO] Found legacy 'codex' references (historical/deprecation context may be expected):"
  cat /tmp/repo_sweep_codex.txt
else
  ok "No legacy 'codex' references found in governance paths."
fi

section "3) Heavy local artifacts (.ops)"
if [[ -d .ops ]]; then
  ops_size="$(du -sh .ops 2>/dev/null | awk '{print $1}')"
  echo ".ops size=${ops_size}"
  du -sh .ops/* 2>/dev/null | sort -hr | head -n 10 || true
  if [[ "${ops_size%M}" =~ ^[0-9]+$ ]] && [[ "${ops_size%M}" -gt 100 ]]; then
    warn ".ops exceeds 100M; archive/prune recommended."
  else
    ok ".ops size within lightweight range or non-MB unit."
  fi
else
  ok ".ops directory not present."
fi

section "4) Constitution scope drift"
if find . -mindepth 1 -maxdepth 1 -type d \( -name "codex-engine" -o -name "codex" -o -name "mcp" -o -name "scripts" \) >/tmp/repo_sweep_scope.txt 2>/dev/null && [[ -s /tmp/repo_sweep_scope.txt ]]; then
  warn "Tracked runtime paths exist in ai-governance scope:"
  cat /tmp/repo_sweep_scope.txt
else
  ok "No tracked runtime paths detected."
fi

section "5) Placeholder file collision"
collision=0
for name in apps engine; do
  if [[ -f "${name}" ]]; then
    warn "'${name}' is a file; expected directory."
    collision=1
  fi
done
if [[ ${collision} -eq 0 ]]; then
  ok "No app/engine placeholder file collision."
fi

section "Result"
if [[ ${warn_count} -eq 0 ]]; then
  ok "Sweep clean."
  exit 0
fi

echo "warnings=${warn_count}"
if [[ ${STRICT} -eq 1 ]]; then
  echo "[FAIL] strict mode enabled."
  exit 2
fi
echo "[DONE] report mode completed with warnings."
