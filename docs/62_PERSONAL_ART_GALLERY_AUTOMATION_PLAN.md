# Personal Art Gallery Automation Plan (Codex Cloud, No-Code Kickoff)

## Goal
Establish a safe, repeatable automation loop for `personal-art-gallery` using Codex Cloud, starting with documentation and operational control before any new code execution.

## Phase 0 (Today): Documentation Lock
- Produce two artifacts:
  1. Lessons learned document
  2. Automation plan document
- Define decision boundaries before enabling autonomous runs.

## Phase 1: Automation Boundary
### Allowed (Autonomous)
- Documentation updates (runbooks, changelogs, release notes).
- Asset inventory checks and consistency checks.
- Draft PR creation for non-risky UI text or style adjustments.

### Human Gate Required
- Payment route changes.
- Public account/bank information changes.
- Any security/policy/workflow changes in ai-governance.
- Any destructive asset operation.

## Phase 2: Daily Automation Loop (Cloud)
1. Read latest repo state and open PR/check status.
2. Produce a one-page daily report:
   - What changed
   - What broke
   - What to do next
3. If low-risk improvements are found, create draft PR only.
4. If high-risk impact is detected, stop and escalate.

## Phase 3: Weekly Product Loop
1. Review engagement signals (scroll depth, mission interactions, support clicks).
2. Propose one UX improvement and one content improvement.
3. Open at most two scoped PRs.
4. Log all decisions in ai-governance docs.

## Operating Rules
- Keep each PR single-purpose and reversible.
- No hidden automation; every action leaves a log trail.
- Prefer support conversion clarity over feature complexity.
- Keep EN/KR behavior deterministic and testable.

## Minimal Cloud Run Checklist
- Confirm branch and target repo.
- Confirm human gate requirements for this run.
- Confirm rollback path exists.
- Confirm output artifact path (report + PR links).

## Exit Criteria for “Automation Ready”
- Daily report generated without manual intervention.
- At least one low-risk draft PR generated successfully.
- No unauthorized high-risk action attempted.
