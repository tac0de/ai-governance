# INTEGRATIONS

## External APIs
- OpenAI `responses`: summarize evidence, explain policy conflicts, and draft strategic scenarios.
- OpenAI `embeddings`: build similarity index across evidence, policies, and historical traces.
- OpenAI `moderation`: gate unsafe or policy-violating input/output content before release.
- OpenAI `files`: reference large evidence bundles for controlled processing.
- OpenAI `batches`: evaluate large policy scenario sets asynchronously.
- Experimental APIs: allowed only on non-core paths, recommendation-only outputs, and mandatory review records.

## Workflow Mapping
- Intake: moderation gate on incoming evidence package.
- Analysis: responses + embeddings for synthesis and retrieval-backed drafting.
- Bulk evaluation: batches over files-backed datasets.
- Release: moderation re-check and evidence/trace reference enforcement.

## MCP Usage
- `example-mcp`: `search`, `fetch_document` for deterministic governance validation path bootstrap.
- Migration note: replace with OpenAI-specific MCP only after registry onboarding and conformance artifacts.

## Permissions Scope
- Least-privilege: only declared MCP capabilities and approved OpenAI API surfaces are allowed.
- Default approval tier: `medium` (`policy_plus_owner`).
- Escalate to `high` when introducing/expanding experimental APIs, changing data boundaries, or extending external permissions.
