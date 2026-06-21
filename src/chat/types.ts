import { RetrievedItem } from '../retrieval/retrieve';

export type DisplayMessage = {
  id: string;
  role: 'user' | 'assistant';
  text: string;
  citations?: RetrievedItem[];
  isStreaming?: boolean;
};
