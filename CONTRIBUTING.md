# Contributing to ai-governance

## Scope
This repository contains:
- `constitution/`: normative source (schemas, reason codes, test vectors)
- `hub/`: deterministic runtime module (`validate`, `run`, `audit`)

## Pull Request Policy
- Create a feature branch for changes.
- Open a pull request to `main`.
- Keep changes focused and small.
- Do not mix unrelated changes in one PR.

## Commit Message Format
Use:

```text
<type>(<scope>): <summary>
```

Examples:
- `docs(readme): align v0 usage with current layout`
- `chore(hooks): tighten secret patterns`
- `fix(hub): enforce deterministic violation ordering`

## Local Checks
Before creating a PR:

```bash
# from repository root
cd hub
npm install
npm run build
npm test
```

## Security Requirements
- Never commit credentials or tokens.
- Never stage `.env`.
- Keep secrets only in local environment.
- Pre-commit hook (`.githooks/pre-commit`) must pass.

## Documentation Rule
- Keep docs in English and consistent with the current repository layout.
- Update docs in the same PR when behavior or paths change.
