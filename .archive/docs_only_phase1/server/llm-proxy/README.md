# LLM Proxy

Small proxy to expose a safe server-side LLM endpoint for browser clients.

Features:
- Bearer token auth via `LLM_PROXY_TOKEN`
- Simple PII guard via `PII_GUARD_ENABLED`
- Model allowlist via `OPENAI_ALLOWED_MODELS`
- Respects `OPENAI_REAL_CALL` to avoid accidental paid calls

Run:

```bash
cd server/llm-proxy
npm install
LLM_PROXY_TOKEN=secret node index.mjs
```
