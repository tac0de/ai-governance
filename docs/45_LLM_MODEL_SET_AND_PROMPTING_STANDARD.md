# 45. LLM Model Set (Max 3) and Prompting Standard

## Objective

Keep the model surface area small (<= 3) and make prompts portable, testable, and low-risk.

## Approved OpenAI model set (<= 3)

The automation layer should only use these model IDs unless a human explicitly approves a change and this document is updated:

- `gpt-5-nano` (default / lowest cost)
- `gpt-5-mini` (standard)
- `gpt-5` (max quality)

Notes:

- This repo defaults to cost-free mode (`OPENAI_REAL_CALL=false`). Model selection matters only when real calls are enabled.
- If model IDs change upstream, update the allowlist, `.env.example`, and record the change in `DECISIONS.md`.

## Official prompt guides (primary sources)

- OpenAI prompt engineering: https://platform.openai.com/docs/guides/prompt-engineering
- OpenAI best practices (help center): https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
- Anthropic prompt engineering: https://docs.anthropic.com/en/docs/prompt-engineering
- Google (Gemini) prompt design strategies: https://ai.google.dev/guide/prompt_best_practices
- Zhipu (BigModel) GLM-5 model docs: https://docs.bigmodel.cn/cn/guide/models/text/glm-5
- Zhipu (BigModel) prompt engineering: https://docs.bigmodel.cn/cn/guide/platform/prompt
- Zhipu (BigModel) privacy policy: https://docs.bigmodel.cn/cn/terms/privacy-policy

## Privacy boundary (non-negotiable)
Policy: No-PII-to-LLM (all providers). If you need "no personal data leakage", do not send personal data to a hosted LLM.

- Enforce input minimization/redaction before model calls.
- Avoid using sensitive identifiers in `user_id` or request metadata.
- Treat output as untrusted and scan/redact before storage or downstream use.
- Use runtime-side PII guard tooling as a best-effort detector on any model-facing prompt/context pack.

## Prompting standard (apply to ChatGPT, API, and ops runs)

Cross-model rules that align with official guidance:

- Be explicit about the task and success criteria.
- Separate instructions from input data (use clear delimiters for context).
- Specify output format (prefer JSON when the output is machine-consumed).
- Provide constraints and non-goals (what not to do).
- Ask clarifying questions only when required to proceed safely; otherwise state minimal assumptions.
- Avoid including secrets in prompts (keys, tokens, recovery codes, private files).

## Canonical prompt contract (template)

Prompt templates must be in English. (Language of the final answer can be requested explicitly.)

```text
SYSTEM:
You are an engineering copilot for platform development.
Hard rules:
- Prefer simple, readable changes.
- Default to action over discussion.
- Do not handle secrets (do not request or store keys/tokens/recovery codes).

DEVELOPER:
Task:
<one sentence>

Context:
<short, factual background>

Constraints:
- Keep changes minimal and reversible.
- If a step is high-risk, stop and ask for approval.

Output format:
- Default: 1) What 2) Why it matters 3) One next action

USER:
<the user request>
```
