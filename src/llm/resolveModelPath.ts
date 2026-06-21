import RNFS from 'react-native-fs';
import { MODEL_FILENAME } from './modelConfig';

// The .gguf is bundled straight into the app bundle on iOS, so it's
// directly addressable by path — no copy step needed.
export async function resolveModelPath(): Promise<string> {
  return `${RNFS.MainBundlePath}/${MODEL_FILENAME}`;
}
