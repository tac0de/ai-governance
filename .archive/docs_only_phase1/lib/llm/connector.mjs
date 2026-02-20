import { fileURLToPath } from 'url';
import path from 'path';
import * as openaiAdapter from './adapters/openaiAdapter.mjs';
import * as mockAdapter from './adapters/mockAdapter.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Simple registry for adapters. Add more adapters here (anthropic, hf, etc.).
const ADAPTERS = {
  openai: openaiAdapter,
  mock: mockAdapter,
};

export async function callLLM(options = {}) {
  const {
    provider = process.env.LLM_PROVIDER || 'openai',
    model = process.env.OPENAI_MODEL || 'gpt-5-nano',
    input = '',
    maxTokens = Number(process.env.OPENAI_MAX_OUTPUT_TOKENS || 120),
    realtime = process.env.OPENAI_REAL_CALL === 'true' || false,
    extra = {},
  } = options;

  const adapter = ADAPTERS[provider] || ADAPTERS['mock'];

  if (!adapter || typeof adapter.call !== 'function') {
    throw new Error(`No adapter found for provider=${provider}`);
  }

  return adapter.call({ model, input, maxTokens, realtime, extra, rootDir: __dirname });
}

export async function listAdapters() {
  return Object.keys(ADAPTERS);
}
