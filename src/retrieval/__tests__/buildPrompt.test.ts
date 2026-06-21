import { getCachedContent } from '../../content/cachedContentProvider';
import { retrieve } from '../retrieve';
import { buildPrompt } from '../buildPrompt';

const content = getCachedContent();

describe('buildPrompt', () => {
  it('includes citation details and the question for a matched query', () => {
    const retrieved = retrieve('how do I change a flat tire', content, 3);
    const messages = buildPrompt('how do I change a flat tire', retrieved);
    expect(messages[0].role).toBe('system');
    expect(messages[1].role).toBe('user');
    expect(messages[1].content).toContain('Changing a Flat Tire');
    expect(messages[1].content).toContain('page 47');
    expect(messages[1].content).toContain("Driver's question: how do I change a flat tire");
  });

  it('tells the model nothing matched when retrieval is empty', () => {
    const messages = buildPrompt('what is the capital of france', []);
    expect(messages[1].content).toContain('no matching excerpts found');
  });
});
