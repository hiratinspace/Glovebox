import { CachedContentItem } from '../data/types';
import { tokenize, tokensApproxMatch } from './tokenize';

// Domain aliases so common driver phrasing ("flat", "tow truck", "won't
// start") lines up with manual section vocabulary, without needing real
// embeddings.
const SYNONYMS: Record<string, string[]> = {
  flat: ['tire', 'spare'],
  tyre: ['tire'],
  tyres: ['tires'],
  jumpstart: ['jump', 'start', 'battery'],
  dead: ['battery', 'jump'],
  wont: ['start'],
  stalled: ['stall', 'engine'],
  tow: ['tow', 'towing'],
  towed: ['tow', 'towing'],
  light: ['light', 'warning'],
  psi: ['pressure', 'tire'],
  oil: ['oil'],
  coolant: ['coolant', 'fluid'],
  fluid: ['fluid', 'oil', 'coolant'],
  jack: ['jack'],
};

function expandTokens(tokens: string[]): string[] {
  const expanded = new Set(tokens);
  for (const tok of tokens) {
    const extras = SYNONYMS[tok];
    if (extras) extras.forEach(e => expanded.add(e));
  }
  return [...expanded];
}

function titleOf(item: CachedContentItem): string {
  return item.contentType === 'manual' ? item.sectionTitle : item.name;
}

function bodyOf(item: CachedContentItem): string {
  if (item.contentType === 'manual') return item.text;
  return `${item.name} ${item.helpType.replace('_', ' ')}`;
}

export type RetrievedItem = {
  item: CachedContentItem;
  score: number;
};

export function retrieve(
  query: string,
  availableContent: CachedContentItem[],
  topK = 3,
): RetrievedItem[] {
  const queryTokens = expandTokens(tokenize(query));
  if (queryTokens.length === 0) return [];

  const docTokenLists = availableContent.map(item => ({
    item,
    titleTokens: tokenize(titleOf(item)),
    bodyTokens: tokenize(bodyOf(item)),
  }));

  // Document frequency for a lightweight IDF — rarer terms across this
  // corpus count for more, so "tow" doesn't get drowned out by filler words.
  const docFreq = new Map<string, number>();
  for (const doc of docTokenLists) {
    const seen = new Set([...doc.titleTokens, ...doc.bodyTokens]);
    for (const tok of seen) docFreq.set(tok, (docFreq.get(tok) ?? 0) + 1);
  }
  const totalDocs = docTokenLists.length;
  const idf = (tok: string) => Math.log(1 + totalDocs / (1 + (docFreq.get(tok) ?? 0)));

  function countMatches(tokens: string[], queryTok: string): number {
    let count = 0;
    for (const tok of tokens) {
      if (tok === queryTok || tokensApproxMatch(tok, queryTok)) count++;
    }
    return count;
  }

  const scored: RetrievedItem[] = docTokenLists.map(doc => {
    let score = 0;
    for (const qTok of queryTokens) {
      const weight = idf(qTok);
      score += countMatches(doc.titleTokens, qTok) * weight * 2.5; // title boost
      score += countMatches(doc.bodyTokens, qTok) * weight;
    }
    return { item: doc.item, score };
  });

  return scored
    .filter(s => s.score > 0)
    .sort((a, b) => b.score - a.score)
    .slice(0, topK);
}
