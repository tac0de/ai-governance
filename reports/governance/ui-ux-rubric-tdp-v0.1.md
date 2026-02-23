# TheDivineParadox UI Quality Rubric v0.1

## Purpose
This rubric defines deterministic UI quality gates for TheDivineParadox so visual quality does not depend on ad-hoc human feedback loops.

## Scope
- Pages: daily vote, result, god state, trace.
- Environments: staging and production candidate builds.
- Inputs: Playwright screenshots (desktop + mobile) and route metadata.

## Scoring Model
- Total score: 0..100.
- Pass threshold: 80.
- Auto-fail rules:
  - Any `critical` issue.
  - Accessibility contrast score < 70.
  - Mobile layout breakage on core actions (vote submit, result read).

## Rubric Categories
1. Visual clarity (weight 25)
- Clear primary action and visual focal point.
- No cluttered sections competing with primary intent.
- Stable spacing rhythm and alignment consistency.

2. Readability (weight 25)
- Heading/body hierarchy is obvious in one glance.
- Line length and density support fast scanning.
- Core state numbers and declaration text remain legible.

3. Consistency (weight 25)
- Reused components keep consistent shape, spacing, and motion behavior.
- Color semantics stay stable across pages.
- Interaction affordances are predictable.

4. Accessibility contrast (weight 25)
- Text/background and UI control contrast support practical readability.
- Focus states are visible and non-ambiguous.
- Key states are not conveyed by color alone.

## Severity Model
- `critical`: blocks comprehension or core action completion.
- `major`: harms trust/readability and should be fixed before release.
- `minor`: polish-level defect; can be scheduled after release only if total score still passes.

## Deterministic Gate Contract
- Evaluation input must include:
  - `service_id`
  - `commit_sha`
  - `env`
  - `route`
  - `viewport`
  - `screenshot_sha256`
- Evaluation output must be JSON-only and schema-validated.
- Every run must store:
  - rubric version (`tdp-ui-rubric-v0.1`)
  - prompt/version id for evaluator
  - screenshot hash and commit hash
  - final verdict and issue list

## Release Gate Policy
- Staging: non-blocking warning when 70..79; hard fail below 70.
- Production candidate: hard fail below 80.
- Architect sign-off remains mandatory for production promotion.

## Operational Notes
- No frontend business logic may be added to bypass quality checks.
- Rubric changes require change-management review and explicit version bump.
- Keep this rubric version frozen for v0.1 release line.
