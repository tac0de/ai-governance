# Contributing

Thanks for contributing.

This repository is intentionally small. Treat it as a governance contract kernel, not an application codebase.

## Before You Change Anything

Please keep these rules:

- Do not add runtime code or product logic.
- Do not add central ownership of service-local traces or service-local state.
- Prefer tightening existing contracts over adding new surfaces.
- Keep changes deterministic and easy to validate.

## What Good Contributions Look Like

Good changes usually do one of these:

- clarify an existing governance contract
- tighten validation logic
- reduce drift between docs and actual contracts
- remove stale or duplicated surfaces
- improve human readability without widening scope

## What To Avoid

Please avoid:

- adding new runtime responsibilities
- adding broad framework code
- adding hidden stateful behavior
- expanding the repository beyond contract, policy, schema, docs, and validation

## Validation

Run this before opening a pull request:

```bash
bash scripts/validate_all.sh
```

A change should pass:

- repository hygiene
- contract validation
- baseline drift checks

## Pull Requests

For pull requests:

- keep the scope narrow
- explain why the change is needed
- describe which contract surface changed
- note any baseline hash updates

Small, clear, deterministic changes are preferred.
