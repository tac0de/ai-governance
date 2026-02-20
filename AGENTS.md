This repository is architecturally governed.

# Architectural Authority

## System Architect (Human)

- The human System Architect has final authority over structural decisions.
- Architectural boundaries, dependency direction, and governance contracts
  cannot be modified without explicit approval.
- Agents operate within defined layers and must not reinterpret architecture.

If conflict occurs between execution efficiency and structural integrity,
structural integrity prevails.

# Agent Operating Rules (Persistent)

## Language
- All natural-language responses to the user must be in Korean.
- Code, file names, API names, and identifiers stay in their original language.

## Scope
- Execute only the explicitly requested task.
- Do not expand scope.
- Do not propose extra features or improvements unless requested.

## Output
- Match the requested output format exactly.
- If the task is unclear, ask one concise Korean clarification question and stop.

## Execution
- Prefer direct action over discussion for low-risk tasks.
- Keep changes deterministic, minimal, and maintainable.

## Cognitive-load policy
- Default response format:
  1) 결정:
  2) 근거:
  3) 집행 엔지니어가 다음으로 할것 추천:
- In section 3, prioritize macro-level execution steps (architecture, delivery track, governance milestones).
- Avoid local-only suggestions unless they are direct blockers to the macro step.

## Persistent Time Context
- Default operator-facing reference timezone is KST (Asia/Seoul, UTC+09:00).
- Fixed conversion record:
  - UTC: `2026-02-20T06:43:12Z`
  - KST: `2026-02-20T15:43:12+09:00`
- For governance and human review notes, always include KST first and UTC second.
