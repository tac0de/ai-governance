# 76. Historiqa Execution Ladder (Simple -> Complex)

## Goal
Ship Historiqa with stable usage first, then expand only when data quality and unit economics are proven.

## Phase 1 (Now): One-tap decision flow
- Input: option click only
- Output: instant save + live aggregate refresh
- KPI:
  - decision completion rate
  - first-session drop-off rate
- Exit rule:
  - completion rate is stable for 2 weeks

## Phase 2 (Next): Guided depth
- Add one optional follow-up step after save:
  - confidence OR reason tag (not both)
- KPI:
  - follow-up completion rate
  - impact on drop-off from Phase 1 baseline
- Exit rule:
  - follow-up adds signal without harming completion trend

## Phase 3 (Later): Monetization layer
- Free:
  - basic aggregate view
- Paid:
  - cohort drill-down
  - weekly insight summary
  - recommendation panel
- KPI:
  - conversion rate
  - ARPU
  - margin trend
- Exit rule:
  - positive margin trend for 2 consecutive weeks

## Hard Rules
- Never add more than one UX variable per cycle.
- Every expansion must keep rollback path.
- If KPI worsens, return to previous stable phase immediately.
