#!/usr/bin/env bash
# Copies an already-downloaded GGUF model into the native locations the app
# expects. Run this yourself after downloading a quantized model — this repo
# does not download model weights automatically.
#
# Usage: scripts/setup-model.sh /path/to/your-model.gguf
#
# Where to get a model: search Hugging Face for "Llama-3.2-1B-Instruct GGUF"
# or "Gemma-2-2B GGUF" and pick a Q4_K_M quantization under ~1.5GB.

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 /path/to/your-model.gguf"
  exit 1
fi

SRC="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
TARGET_NAME="llama-3.2-1b-instruct-q4_k_m.gguf"

if [ ! -f "$SRC" ]; then
  echo "No file found at $SRC"
  exit 1
fi

ANDROID_DEST_DIR="$REPO_ROOT/android/app/src/main/assets/models"
mkdir -p "$ANDROID_DEST_DIR"
cp "$SRC" "$ANDROID_DEST_DIR/$TARGET_NAME"
echo "Copied model to $ANDROID_DEST_DIR/$TARGET_NAME"

IOS_DEST="$REPO_ROOT/ios/$TARGET_NAME"
cp "$SRC" "$IOS_DEST"
echo "Copied model to $IOS_DEST"
echo
echo "Next step for iOS: open the Xcode project, drag $TARGET_NAME into the"
echo "project navigator, and make sure it's checked under the app target's"
echo "'Copy Bundle Resources' build phase (Xcode will usually prompt you to"
echo "add it automatically when you drag it in)."
