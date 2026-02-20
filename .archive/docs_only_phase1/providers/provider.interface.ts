import { EventProposal } from '../game-engine/types/event.types';

export interface Provider {
  /**
   * Generate a structured EventProposal from an opaque input.
   * Implementations must not perform side-effects at import-time.
   */
  generateStructuredEvent(input: unknown): Promise<EventProposal>;
}

export default Provider;
