export async function call({ model, input }) {
  // Simple deterministic mock: echo with prefix and small transformation
  const text = `echo(model=${model}): ${String(input).slice(0, 100)}`;
  return { provider: 'mock', model, text, tokens: 0, meta: { mocked: true } };
}
