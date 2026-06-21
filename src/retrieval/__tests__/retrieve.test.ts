import { getCachedContent } from '../../content/cachedContentProvider';
import { retrieve } from '../retrieve';

const content = getCachedContent();

function topIds(query: string, topK = 3) {
  return retrieve(query, content, topK).map(r => r.item.id);
}

describe('retrieve', () => {
  it('finds the tire-change procedure for a plain-English flat tire question', () => {
    const ids = topIds('how do I change a flat tire');
    expect(ids).toContain('camry-tire-change');
  });

  it('finds the jack point section', () => {
    const ids = topIds("what's my jack point");
    expect(ids).toContain('camry-jack-point');
  });

  it('finds the jump-start section for a dead battery phrasing', () => {
    const ids = topIds('my car is dead, how do I jumpstart it');
    expect(ids).toContain('camry-jump-start');
  });

  it('finds the check engine light section', () => {
    const ids = topIds('check engine light is on, what do I do');
    expect(ids).toContain('camry-warning-check-engine');
  });

  it('finds a tow waypoint for nearest-tow questions', () => {
    const ids = topIds("where's the nearest tow");
    const towIds = ['wp-joes-towing', 'wp-hwy9-tow', 'wp-aaa-tow'];
    expect(ids.some(id => towIds.includes(id))).toBe(true);
  });

  it('finds tire pressure spec for a PSI question', () => {
    const ids = topIds('what tire pressure psi should I run');
    expect(ids).toContain('camry-tire-pressure-spec');
  });

  it('tolerates a minor typo', () => {
    const ids = topIds('how do I check coolent level');
    expect(ids).toContain('camry-check-coolant');
  });

  it('returns nothing for a completely unrelated query', () => {
    const results = retrieve('what is the capital of france', content, 3);
    expect(results.length).toBe(0);
  });
});
