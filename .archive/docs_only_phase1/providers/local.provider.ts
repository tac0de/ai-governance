import { Provider } from './provider.interface';
import { EventProposal } from '../game-engine/types/event.types';

export class LocalProvider implements Provider {
  async generateStructuredEvent(input: unknown): Promise<EventProposal> {
    // Minimal deterministic local stub. No external calls.
    const now = new Date().toISOString();
    const proposal: EventProposal = {
      event: {
        idempotency_key: `local:${now}`,
        created_at: now,
        type: 'WORLD_NEWS_POST',
        params: {
          headline: typeof input === 'string' ? input : 'local-stub-headline',
          body: 'This is a local stub event generated for testing.',
        },
      },
      proposal_source: 'local',
      confidence: 0.01,
    };
    return proposal;
  }
}

export default LocalProvider;
