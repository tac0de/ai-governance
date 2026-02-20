import { strict as assert } from 'assert';
import { dispatchIncoming } from '../game-engine/dispatcher/eventDispatcher';

describe('dispatchIncoming (validation wrapper)', () => {
  it('returns ERROR for invalid input', async () => {
    const res = await dispatchIncoming({ foo: 1 });
    assert.equal(res.status, 'ERROR');
  });

  it('returns OK for a valid event object', async () => {
    const now = new Date().toISOString();
    const ev = {
      idempotency_key: 'x1',
      created_at: now,
      type: 'WORLD_NEWS_POST',
      params: { headline: 'h', body: 'b' },
    };
    const res = await dispatchIncoming(ev);
    assert.equal(res.status, 'OK');
  });
});
