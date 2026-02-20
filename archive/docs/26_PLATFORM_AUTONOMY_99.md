# Platform Autonomy (99%, Security-First)

## Objective
Define autonomy policy for platform operations while keeping `ai-governance` as governance-only.

## Boundary
- `ai-governance`: policy, routing rules, audit records, CI/workflow governance.
- `engine`: runtime loop execution, adapters, domain task automation.

`ai-governance` does not execute domain/runtime loops directly.

## Main-hub executable checks
```bash
bash tools/repo_sweep.sh --strict
bash tools/main_hub_final_check.sh
```

Optional local parse summary:
```bash
node tools/repo_parser.js --repo tac0de/ai-governance --branch main
```

## Remote governance workflows in ai-governance
- `.github/workflows/autonomy-99-remote.yml`
- `.github/workflows/security-baseline.yml`

These workflows are governance and reporting surfaces; domain execution logic belongs to `engine`.

## Human gate policy
- Keep security checks mandatory.
- Escalate destructive or identity-bound actions to human approval.
- Record decision evidence in `DECISIONS.md`, `MASTER_CONTEXT.md`, and `LOGS/`.
