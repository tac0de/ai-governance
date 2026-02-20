// NPC module placeholder: interfaces and stubs

export interface NPC {
  id: string;
  name?: string;
  state?: string;
}

export function createNpc(id: string, name?: string): NPC {
  return { id, name };
}

export default NPC;
