import { Provider } from './provider.interface';
import { EventProposal } from '../game-engine/types/event.types';

// OpenAI provider stub: placeholder for future provider implementation.
// IMPORTANT: Do not add provider-specific dependencies or real API calls here.
export class OpenAIProvider implements Provider {
  async generateStructuredEvent(_input: unknown): Promise<EventProposal> {
    throw new Error('OpenAIProvider.generateStructuredEvent is not implemented yet.');
  }
}

export default OpenAIProvider;
