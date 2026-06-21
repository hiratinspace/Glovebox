import { Platform } from 'react-native';
import RNFS from 'react-native-fs';
import { MODEL_FILENAME } from './modelConfig';

// iOS bundles the .gguf straight into the app bundle, so it's directly
// addressable by path. Android can't mmap a model out of the APK's asset
// zip, so we copy it into the writable documents dir once on first launch.
export async function resolveModelPath(): Promise<string> {
  if (Platform.OS === 'ios') {
    return `${RNFS.MainBundlePath}/${MODEL_FILENAME}`;
  }

  const destPath = `${RNFS.DocumentDirectoryPath}/${MODEL_FILENAME}`;
  const alreadyCopied = await RNFS.exists(destPath);
  if (!alreadyCopied) {
    await RNFS.copyFileAssets(`models/${MODEL_FILENAME}`, destPath);
  }
  return destPath;
}
