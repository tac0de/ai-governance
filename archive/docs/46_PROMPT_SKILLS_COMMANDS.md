# Prompt Skills (Command Doc)

Purpose: reusable prompt templates that reduce token/iteration cost while preserving operational safety.

Global constraints (apply to all skills)
- No-PII-to-LLM: do not paste personal data, access tokens, recovery codes, or private logs into any hosted LLM.
- Prefer deterministic outputs: request structured results, explicit file paths, and explicit verification commands.
- Keep responses minimal and concrete: focus on the next actionable step and the smallest sufficient change set.

How to use
- Copy one template below into ChatGPT/Codex and fill in the brackets.
- Keep inputs short. Prefer linking file paths and exact commands over narrative.

---

## Skill: `BUGFIX`

One-line intent: reproduce a bug, isolate root cause, patch minimally, and verify.

Template

```text
[SKILL] BUGFIX

Repo:
- Root: [absolute or workspace-relative path]

Problem:
- Observed: [what happens, exact error text if any]
- Expected: [what should happen]
- Scope: [one sentence]

Repro:
- Command(s): [exact commands]
- Inputs: [files/flags]

Constraints:
- Do not introduce new dependencies unless required.
- Keep the diff small and readable.
- Add/adjust tests if feasible.
- No secrets/PII in logs, code, or prompts.

Output contract:
- Provide a patch (file edits) with exact file paths.
- Provide verification commands and expected outcomes.
- If not reproducible, state what is missing and the smallest next diagnostic step.
```

---

## Skill: `DOC_WRITE`

One-line intent: produce or revise documentation with a stable structure and low ambiguity.

Template

```text
[SKILL] DOC_WRITE

Target:
- File(s): [path(s)]
- Audience: [engineers / researchers / operators]
- Purpose: [one sentence]

Content requirements:
- Must be in English.
- Research-friendly vocabulary, no subjective emotional language.
- Include: [required sections]
- Exclude: [anything to avoid]

Context:
- Source files to reference: [paths]
- Non-negotiable policies: [e.g., No-PII-to-LLM, max-3 model allowlist]

Output contract:
- Provide a patch (file edits) only.
- Keep it concise. Prefer checklists and explicit commands.
- If a fact is unknown/unstable, mark it as UNKNOWN rather than guessing.
```

---

## Skill: `SAFE_PUBLISH`

One-line intent: prepare a repository for public release with best-effort safety checks.

Template

```text
[SKILL] SAFE_PUBLISH

Repo:
- Root: [path]
- Publish target: [GitHub repo name] / [GitHub Pages] / [npm package] / [other]

What will be public:
- Paths included: [paths]
- Paths excluded: [paths]

Safety constraints:
- No credentials, tokens, recovery codes, private keys, or personal data in the repo.
- Validate no accidental uploads of build artifacts that contain secrets.

Checks to run (preferred):
- `git status` and `git diff --stat`
- Search for common secrets: `rg -n \"(BEGIN( RSA)? PRIVATE KEY|ghp_|github_pat_|sk-[A-Za-z0-9]|AKIA|AIza|xox[baprs]-)\" -S .`
- Best-effort PII scan: run runtime-side PII guard command in your execution repository (if present).

Output contract:
- Provide an ordered checklist of exactly what to do next.
- If any risk is found, stop and list the exact file path(s) and what to remove/rotate.
```
