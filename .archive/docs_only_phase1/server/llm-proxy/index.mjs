import express from 'express';
import bodyParser from 'body-parser';
import { callLLM } from '../../lib/llm/connector.mjs';

const app = express();
app.use(bodyParser.json({ limit: '512kb' }));

const PORT = process.env.LLM_PROXY_PORT || 4123;
const TOKEN = process.env.LLM_PROXY_TOKEN || '';
const MODEL_ALLOWLIST = (process.env.OPENAI_ALLOWED_MODELS || 'gpt-5-nano,gpt-5-mini,gpt-5').split(',');
const PII_GUARD_ENABLED = (process.env.PII_GUARD_ENABLED || 'false') === 'true';

function containsPII(text = '') {
  if (!text) return false;
  // simple heuristics: emails, long digit sequences (phone/ids)
  const email = /[\w.+-]+@[\w-]+\.[\w.-]+/;
  const longDigits = /\d{7,}/;
  return email.test(text) || longDigits.test(text);
}

app.post('/llm', async (req, res) => {
  try {
    const auth = String(req.headers.authorization || '');
    if (TOKEN && auth !== `Bearer ${TOKEN}`) {
      return res.status(401).json({ error: 'unauthorized' });
    }

    const { provider = process.env.LLM_PROVIDER || 'openai', model = process.env.OPENAI_MODEL || 'gpt-5-nano', input = '', maxTokens = Number(process.env.OPENAI_MAX_OUTPUT_TOKENS || 120) } = req.body || {};

    // Model allowlist enforcement (basic)
    if (provider === 'openai' && !MODEL_ALLOWLIST.includes(model)) {
      return res.status(403).json({ error: 'model_not_allowed', model });
    }

    // No-PII guard
    if (PII_GUARD_ENABLED && containsPII(input)) {
      return res.status(400).json({ error: 'pii_detected' });
    }

    // Gating: if OPENAI_REAL_CALL not enabled and provider is openai, fall back to mock adapter
    const realtime = (process.env.OPENAI_REAL_CALL === 'true');
    const effectiveProvider = provider === 'openai' && !realtime ? 'mock' : provider;

    const out = await callLLM({ provider: effectiveProvider, model, input, maxTokens, realtime });
    return res.json(out);
  } catch (err) {
    console.error('llm-proxy error:', err?.message || String(err));
    return res.status(500).json({ error: 'server_error', message: err?.message || String(err) });
  }
});

app.get('/healthz', (req, res) => res.json({ status: 'ok' }));

app.listen(PORT, () => console.log(`llm-proxy listening on ${PORT}`));
