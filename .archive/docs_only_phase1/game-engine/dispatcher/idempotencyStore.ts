/**
 * Idempotency store interface and a tiny in-memory stub.
 * This is a local, additive stub only — not wired into any runtime.
 */
export interface IdempotencyStore {
  hasProcessed(idempotencyKey: string): Promise<boolean>;
  markProcessed(idempotencyKey: string): Promise<void>;
}

export class InMemoryIdempotencyStore implements IdempotencyStore {
  private store = new Set<string>();

  async hasProcessed(idempotencyKey: string): Promise<boolean> {
    return this.store.has(idempotencyKey);
  }

  async markProcessed(idempotencyKey: string): Promise<void> {
    this.store.add(idempotencyKey);
  }
}

export default InMemoryIdempotencyStore;
