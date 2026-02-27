# CAPABILITIES

## Capability Catalog
- Name: `evaluate_group_session_state`
- Inputs: `session_id`, `turn_index`, `participant_stats_ref`, `policy_profile`.
- Outputs: `session_state`, `risk_flags`, `trace_ref`.
- Failure modes: missing required stats, stale session snapshot.
- Approval implications: 정책 경계 변경 시 high tier.

- Name: `select_next_learning_intervention`
- Inputs: `session_state`, `learning_goal_ref`, `recent_actions_ref`.
- Outputs: `intervention_plan`, `priority`, `justification_ref`.
- Failure modes: goal reference mismatch, unsupported intervention type.
- Approval implications: 개입 템플릿 확장 시 high tier.

- Name: `enforce_turn_and_participation_policy`
- Inputs: `participant_events_ref`, `turn_policy_version`, `idempotency_key`.
- Outputs: `policy_verdict`, `allowed_actions`, `degrade_notice`.
- Failure modes: policy version drift, idempotency collision.
- Approval implications: turn/participation 규칙 변경 시 high tier.

- Name: `emit_learning_session_trace_contract`
- Inputs: `intent_ref`, `policy_ref`, `evidence_refs`, `verdict_payload`.
- Outputs: `trace_record_ref`, `append_status`.
- Failure modes: missing evidence hash, append-only violation.
- Approval implications: trace 계약 변경 시 high tier.
