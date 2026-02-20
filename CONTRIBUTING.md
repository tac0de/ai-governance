# Contributing to ai-governance

## Core Philosophy

This repository follows the **Mastermind** operating system philosophy:
- **Simplicity first**: Choose structures anyone can read and modify
- **Execution first**: Small execution and rapid verification over lengthy discussion
- **Human-centered**: AI is a tool; humans hold final responsibility
- **Safe speed**: Verify security, cost, and recoverability before moving fast
- **Decision by logs**: Judge by results, not intuition

---

## Workflow Rules

### All Changes Must Go Through PR
- **No direct pushes to `main` branch**
- All changes require a Pull Request
- Owner (admin) can bypass review requirements but still uses PR workflow

### Review Requirements
- **Minimum 1 approval** required to merge
- **No self-approval**: You cannot approve your own PR
- **Last push approval**: Recent commits require new approval

### Branch Protection
The `main` branch is protected with:
- PR required for all merges
- At least 1 reviewer approval
- Conversation resolution required before merge
- Linear history required
- Force push and deletion disabled

---

## Commit Message Guidelines

### Format
```
<type>(<scope>): <简短说明>

[optional body]
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `refactor`: Code refactoring
- `chore`: Maintenance, tooling
- `security`: Security-related changes

### Examples
```
feat(kernel): add new gate validation rule
fix(mcp): resolve obsidian sync timeout
docs(readme): update installation steps
security(token): remove exposed API key
```

### Rules
- Use English (or Korean with English summary)
- Keep subject line under 72 characters
- Include "why" in body when needed

---

## Large Structural Changes

### When to Open an Issue First
- Architecture changes affecting multiple modules
- New directory structures
- Breaking changes to existing workflows
- New integrations or external service connections

### Process
1. Open an Issue describing the proposed change
2. Discuss approach with maintainer
3. Get agreement before creating PR
4. Include implementation plan in PR description

---

## Design Philosophy

### ai-hub / ai-governance Direction

1. **Local-first, remote-extended**
   - Write and test locally
   - Deploy and run remotely

2. **Contract-based development**
   - Define API contracts first
   - Input/output/state transitions clearly specified
   - Results stored in standard format (`run_result.json`)

3. **Conservative automation**
   - Non-destructive by default
   - Minimum privilege principle
   - Safe stop on failure
   - Human approval path for high-risk operations

4. **Operational viability over demo**
   - Prefer "system that runs continuously" over " flashy demo"
   - Design for failure, retry, logging, and recovery from the start

---

## Pre-commit Checks

Before submitting PR, run:
```bash
# Scope and structure validation
bash tools/repo_sweep.sh --strict

# Final constitution scope check
bash tools/main_hub_final_check.sh
```

---

## Code Review Values

- Focus on correctness and safety
- Suggest improvements, not just criticisms
- Approve when safe to merge
- Block when security or stability at risk

---

## Questions?

- Open an Issue for discussion
- Check existing docs in `docs/`
- Review past decisions in `DECISIONS.md`
