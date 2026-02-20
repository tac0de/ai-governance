# Offline Work Checklist (High-Privilege Sessions)

## Goal
Run local high-privilege work with reduced network risk while keeping ai-governance deterministic.

## 1) Before Going Offline
- Confirm branch and target scope: control-plane paths only (`.github/`, `docs/`, `tools/`, `contracts/`, `LOGS/`).
- Run `git status -sb` and ensure you understand all local diffs.
- Close unrelated apps/tabs that can auto-sync or upload files.
- Verify `.env` and secret files are not staged.
- Decide explicit end condition (example: "finish guard script + run local checks").

## 2) During Offline Work
- Disable Wi-Fi or unplug network before editing high-risk files.
- Keep changes single-purpose; avoid broad refactors.
- Prefer local checks first:
  - `bash tools/repo_sweep.sh --strict`
  - `bash tools/main_hub_final_check.sh`
- Do not create or copy credentials into tracked files.
- Keep commit messages clear and reversible.

## 3) Before Reconnecting
- Re-run `git status -sb` and `git diff --name-only`.
- Re-check changed paths stay inside control-plane boundaries.
- Review `.env` and shell history for accidental secret exposure.
- Remove temporary files containing tokens, traces, or dumps.

## 4) Reconnect and Publish
- Reconnect network only after local checks pass.
- Push minimal, reviewed commits.
- Watch CI result and fix immediately if guard fails.
- If any secret may have been exposed, rotate first and then continue.

## Hard Stop Rules
- Stop immediately if unexpected files appear or diffs explode.
- Stop immediately if a command tries to access unknown remote endpoints.
- Stop immediately if you cannot explain each staged file in one line.
