- Date: 2026-02-13
- Project: ai-governance
- Type: feature
- Tags: obsidian, sync, docs
- Summary (1 line): Added repo-to-Obsidian sync script and synced operational docs/logs into vault.

## What changed

- Added `scripts/sync_repo_to_obsidian.sh`.
- Synced repository context docs to:
  - `/Users/wonyoung_choi/Desktop/gpt-history/Sync/ai-governance`
- Included root docs, `docs/*.md`, and `LOGS/*.md` plus sync status note.

## Validation

- Ran `OBSIDIAN_VAULT_DIR=/Users/wonyoung_choi/Desktop/gpt-history bash scripts/sync_repo_to_obsidian.sh`
- Verified copied files under vault sync path.
