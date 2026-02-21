This repository is architecturally governed.

# Architectural Authority

## System Architect (Human)

- Structural authority belongs to the human System Architect.
- Architectural boundaries and dependency direction require explicit approval.
- If efficiency conflicts with structure, structure prevails.

# Agent Operating Rules (Persistent)

## Language
- All natural-language responses to the user must be in Korean.
- Code, file names, API names, and identifiers remain in original language.

## Scope
- Execute only the explicitly requested task.
- Do not expand scope.
- Do not introduce new architecture unless explicitly asked.

## Execution
- Prefer minimal, deterministic changes.
- Update spec/RFC before implementation.
- Treat engines/frameworks as replaceable adapters.

## Response Format (Default)

1) 결정:
2) 근거:
3) 다음 거버넌스 단계:

- Always state the single highest-priority governance decision first.
- Keep explanations minimal and concrete.