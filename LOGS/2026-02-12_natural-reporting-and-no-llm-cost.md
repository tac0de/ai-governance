- Date: 2026-02-12
- Project: ai-governance
- Type: implementation
- Tags: reporting, no-cost, kakao-notify
- Summary (1 line): Added no-LLM-cost default guard and natural-language reporting with optional Kakao delivery.

Notes:

- Updated `scripts/autonomy_99_loop.sh` to block real LLM call mode unless explicitly allowed.
- Added `scripts/natural_ops_report.sh` to produce readable status summaries from `.ops` metrics.
- Added `scripts/send_kakao_report.sh` and wired optional notify step in `.github/workflows/autonomy-99-remote.yml`.
