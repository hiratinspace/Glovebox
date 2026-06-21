import { CachedContentItem } from '../data/types';
import { MANUAL_CHUNKS } from '../data/manualChunks';
import { HELP_WAYPOINTS } from '../data/waypoints';

export type CachedContentProvider = () => CachedContentItem[];

// Standalone default: every chunk for every vehicle plus every waypoint.
// Travel Mode will call setCachedContentProvider() with a function that
// returns only the chunks for the trip's vehicleId and the waypoints along
// the chosen route — a one-line swap, no changes needed at call sites.
const defaultProvider: CachedContentProvider = () => [
  ...MANUAL_CHUNKS,
  ...HELP_WAYPOINTS,
];

let activeProvider: CachedContentProvider = defaultProvider;

export function setCachedContentProvider(provider: CachedContentProvider): void {
  activeProvider = provider;
}

export function resetCachedContentProvider(): void {
  activeProvider = defaultProvider;
}

export function getCachedContent(): CachedContentItem[] {
  return activeProvider();
}
