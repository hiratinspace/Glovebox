// The GGUF binary is too large to ship through Metro's JS bundle, so it is
// bundled as a native resource instead and referenced by filename here.
//
// iOS:     add the file to the Xcode project as a bundle resource
//          (drag into the project, check "Copy items if needed" + the app
//          target's "Copy Bundle Resources" build phase).
// Android: place the file at android/app/src/main/assets/models/<filename>.
//
// See scripts/setup-model.sh, which copies an already-downloaded .gguf file
// into both locations for you.
export const MODEL_FILENAME = 'llama-3.2-1b-instruct-q4_k_m.gguf';
