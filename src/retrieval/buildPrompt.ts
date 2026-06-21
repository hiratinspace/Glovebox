import { citationDetail } from './citation';
import { RetrievedItem } from './retrieve';

export type ChatMessage = {
  role: 'system' | 'user';
  content: string;
};

const SYSTEM_PROMPT = `You are an offline roadside assistant copilot for a stranded driver. ` +
  `Answer ONLY using the provided excerpts below — never use outside knowledge, and never guess. ` +
  `For manual content, cite the section title and page number. For nearby-help content, state the ` +
  `name, distance, and mile marker. If none of the excerpts cover the question, say so clearly ` +
  `instead of guessing. Keep answers short, calm, and actionable.`;

export function buildPrompt(query: string, retrievedItems: RetrievedItem[]): ChatMessage[] {
  const excerptsBlock = retrievedItems.length
    ? retrievedItems
        .map((r, i) => `[${i + 1}] ${citationDetail(r.item)}\n${excerptText(r)}`)
        .join('\n\n')
    : '(no matching excerpts found)';

  return [
    { role: 'system', content: SYSTEM_PROMPT },
    {
      role: 'user',
      content: `Excerpts:\n${excerptsBlock}\n\nDriver's question: ${query}`,
    },
  ];
}

function excerptText(retrieved: RetrievedItem): string {
  const { item } = retrieved;
  if (item.contentType === 'manual') return item.text;
  return `Contact: ${item.phoneIfKnown ?? 'no phone on file'}.`;
}
