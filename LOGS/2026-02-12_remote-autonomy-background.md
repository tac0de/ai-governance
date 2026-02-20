- Date: 2026-02-12
- Project: ai-governance
- Type: implementation
- Tags: github-actions, autonomy, human-gate
- Summary (1 line): Added remote background autonomy workflow with human-gate issue escalation.

Notes:

- Added `.github/workflows/autonomy-99-remote.yml` with schedule + manual dispatch triggers.
- Implemented exit-code handling: normal completion on 0, human-gate escalation flow on 3.
- Uploaded `.ops` artifacts and added job summary output for observability.
