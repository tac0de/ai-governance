// Economics module placeholder: types and skeletal interfaces

export interface MarketSnapshot {
  timestamp: string; // ISO
  inflation_rate?: number;
}

export function sampleMarket(): MarketSnapshot {
  return { timestamp: new Date().toISOString() };
}

export default MarketSnapshot;
