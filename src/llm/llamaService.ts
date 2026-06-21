import { initLlama, LlamaContext, RNLlamaOAICompatibleMessage } from 'llama.rn';
import { resolveModelPath } from './resolveModelPath';
import { ChatMessage } from '../retrieval/buildPrompt';

const STOP_WORDS = [
  '</s>', '<|end|>', '<|eot_id|>', '<|end_of_text|>', '<|im_end|>', '<|EOT|>',
  '<|END_OF_TURN_TOKEN|>', '<|end_of_turn|>', '<|endoftext|>',
];

let contextPromise: Promise<LlamaContext> | null = null;

// Cached singleton: the model only needs to be loaded into memory once per
// app session, regardless of how many screens/components ask for it.
export function loadLlamaContext(onProgress?: (progress: number) => void): Promise<LlamaContext> {
  if (!contextPromise) {
    contextPromise = (async () => {
      const modelPath = await resolveModelPath();
      return initLlama(
        {
          model: `file://${modelPath}`,
          n_ctx: 2048,
          n_gpu_layers: 99,
        },
        onProgress,
      );
    })();
  }
  return contextPromise;
}

export async function runInference(
  context: LlamaContext,
  messages: ChatMessage[],
  onToken: (partialText: string) => void,
): Promise<string> {
  const result = await context.completion(
    {
      messages: messages as RNLlamaOAICompatibleMessage[],
      n_predict: 256,
      stop: STOP_WORDS,
    },
    data => {
      if (data.token) onToken(data.token);
    },
  );
  return result.text;
}
