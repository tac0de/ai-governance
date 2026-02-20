# Naming RFC: Adopt `kernel` Naming Family

## Decision
- Legacy alias naming is deprecated and must be replaced.
- Official naming family is `kernel-*`.

## Target Names
- `ai-governance` remains `ai-governance` (constitution repo).
- Runtime repo naming standard: `kernel-engine`.
- Internal package/module namespace standard: `kernel/*`.

## Migration Rules
- New files, folders, package names, and docs must not introduce legacy alias identifiers.
- Existing legacy identifiers are transitional aliases only during migration.
- PR#2 (engine migration PR) must perform structural rename for runtime paths where feasible without behavior changes.

## Compatibility Window
- Keep temporary aliases for up to 2 releases.
- After the window, remove alias names and keep `kernel` only.

## Review Gate
- Any PR introducing new legacy alias terms is blocked unless explicitly marked as legacy-compat shim.
