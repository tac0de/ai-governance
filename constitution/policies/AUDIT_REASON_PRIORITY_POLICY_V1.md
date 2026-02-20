# Audit Reason Priority Policy v1

## Policy ID
ARPP-V1

## Scope
Defines deterministic `reason_code` priority for REJECT decisions in `audit`.

## Priority Order (lowest number = highest priority)
1. `HUNBUP_PLAN_SCHEMA_INVALID`
2. `HUNBUP_RESULT_SCHEMA_INVALID`
3. `HUNBUP_EVIDENCE_SCHEMA_INVALID`
4. `HUNBUP_ACTION_TYPE_NOT_ALLOWED`
5. `HUNBUP_COMMAND_ID_NOT_ALLOWED`
6. `HUNBUP_ENV_KEY_NOT_ALLOWED`
7. `HUNBUP_TIMEOUT_EXCEEDED`
8. `HUNBUP_EVIDENCE_MISSING_REQUIRED_FIELD`
9. `HUNBUP_HASH_MISMATCH`
10. `HUNBUP_NONDETERMINISTIC_OUTPUT`

## Deterministic Tie-break
If multiple violations share same priority, sort by:
1. `code` (lexicographic)
2. `path` (lexicographic)
3. `message` (lexicographic)

The first sorted violation becomes `audit.reason_code`.
