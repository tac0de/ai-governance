import { strict as assert } from 'assert';
import { dispatchEvent } from '../game-engine/dispatcher/eventDispatcher';
import type { Event } from '../game-engine/types/event.types';

describe('eventDispatcher (basic)', () => {
  const now = new Date().toISOString();

  const samples: Event[] = [
    {
      idempotency_key: 't1',
      created_at: now,
      type: 'WORLD_NEWS_POST',
      params: { headline: 'h', body: 'b' },
    },
    {
      idempotency_key: 't2',
      created_at: now,
      type: 'QUEST_ISSUE',
      params: { questId: 'q1', description: 'desc' },
    },
    {
      idempotency_key: 't3',
      created_at: now,
      type: 'NPC_STATE_TRANSITION',
      params: { npcId: 'n1', from_state: 'A', to_state: 'B' },
    },
    {
      idempotency_key: 't4',
      created_at: now,
      type: 'ECONOMY_ADJUST',
      params: { currency: 'GOLD', delta: 1, target: 'GLOBAL' },
    },
    {
      idempotency_key: 't5',
      created_at: now,
      type: 'ITEM_DROP_TABLE_ADJUST',
      params: { itemId: 'i1', drop_rate: 0.5 },
    },
  ];

  for (const ev of samples) {
    it(`handles ${ev.type} -> status OK`, async () => {
      const res = await dispatchEvent(ev);
      assert.equal(res.status, 'OK');
      assert.ok(res.handler, 'handler should be present');
    });
  }

  it('handles ECONOMY_ADJUST with delta 0 -> status RETRY', async () => {
    const now = new Date().toISOString();
    const ev = {
      idempotency_key: 't0',
      created_at: now,
      type: 'ECONOMY_ADJUST',
      params: { currency: 'GOLD', delta: 0, target: 'GLOBAL' },
    } as any;
    const res = await dispatchEvent(ev);
    assert.equal(res.status, 'RETRY');
  });
});
