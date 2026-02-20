import { strict as assert } from 'assert';
import { dispatchIncoming, configureRetry } from '../game-engine/dispatcher/eventDispatcher';

describe('dispatchIncoming retry orchestration', () => {
  it('retries ECONOMY_ADJUST with delta 0 up to maxRetry and returns RETRY', async () => {
    // configure zero delay and small retry limit for fast test
    configureRetry({ policy: 'exponential-backoff', maxRetry: 2, baseDelayMs: 0 });
    const now = new Date().toISOString();
    const ev = {
      idempotency_key: 'retry-test-1',
      created_at: now,
      type: 'ECONOMY_ADJUST',
      params: { currency: 'GOLD', delta: 0, target: 'GLOBAL' },
    };

    const res = await dispatchIncoming(ev);
    assert.equal(res.status, 'RETRY');
    // retryCount should reflect attempts (here == maxRetry)
    assert.equal(res.meta?.retryCount, 2);
    assert.equal(res.meta?.maxRetry, 2);
  });
});
