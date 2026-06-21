const STOPWORDS = new Set([
  'a', 'an', 'the', 'is', 'are', 'was', 'were', 'do', 'does', 'did', 'i', 'my',
  'me', 'to', 'of', 'in', 'on', 'for', 'and', 'or', 'it', 'this', 'that',
  'what', 'where', 'how', 'when', 'with', 'so', 'be', 'have', 'has', 'can',
  'should', 'would', 'will', 'there', 'near', 'nearest', 'closest',
]);

export function tokenize(text: string): string[] {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, ' ')
    .split(/\s+/)
    .filter(tok => tok.length > 0 && !STOPWORDS.has(tok));
}

// Levenshtein distance, capped early for short tokens — used to tolerate
// typos like "tyre"/"tire" or "presure"/"pressure" without an extra dep.
export function levenshtein(a: string, b: string): number {
  if (a === b) return 0;
  const m = a.length;
  const n = b.length;
  if (m === 0) return n;
  if (n === 0) return m;
  const prev = new Array(n + 1);
  const curr = new Array(n + 1);
  for (let j = 0; j <= n; j++) prev[j] = j;
  for (let i = 1; i <= m; i++) {
    curr[0] = i;
    for (let j = 1; j <= n; j++) {
      const cost = a[i - 1] === b[j - 1] ? 0 : 1;
      curr[j] = Math.min(prev[j] + 1, curr[j - 1] + 1, prev[j - 1] + cost);
    }
    for (let j = 0; j <= n; j++) prev[j] = curr[j];
  }
  return prev[n];
}

export function tokensApproxMatch(a: string, b: string): boolean {
  if (a === b) return true;
  if (a.length < 4 || b.length < 4) return false;
  return levenshtein(a, b) <= 1;
}
