Glovebox is an offline AI copilot for stranded drivers: on-device LLM inference (via
[llama.rn](https://github.com/mybigday/llama.rn)) with keyword-based RAG over vehicle owner's
manuals, no network required after first launch. iOS only.

## Prerequisites (macOS)

- Xcode (full install from the App Store, not just Command Line Tools) — needed for the iOS
  Simulator and to build the native project.
- Node.js and npm.
- CocoaPods, installed via the Ruby bundler (see Step 2 below).

## Step 1: Install JS dependencies

```sh
npm install
```

## Step 2: Bundle a GGUF model (required, one-time)

This repo does not ship or download model weights.

1. Download a quantized GGUF model — search Hugging Face for "Llama-3.2-1B-Instruct GGUF" or
   "Gemma-2-2B GGUF" and grab a Q4_K_M quantization under ~1.5GB.
2. Run `scripts/setup-model.sh /path/to/your-model.gguf` — this copies it into `ios/`.
3. Open `ios/Glovebox.xcodeproj` in Xcode, drag the copied `.gguf` file into the project
   navigator, and confirm it's checked under the app target's "Copy Bundle Resources" build
   phase (Xcode usually prompts you to add it automatically when you drag it in).

## Step 3: Install CocoaPods dependencies

First time only, install the Ruby bundler's gems (CocoaPods itself):

```sh
bundle install
```

Then, and every time you update native dependencies:

```sh
bundle exec pod install --project-directory=ios
```

## Step 4: Run the app

Start Metro in one terminal:

```sh
npm start
```

In another terminal, build and launch on the iOS Simulator:

```sh
npm run ios
```

This boots the default simulator, builds the app, and installs it. You can also open
`ios/Glovebox.xcworkspace` directly in Xcode and hit Run — useful for picking a specific
simulator device or running on a physical iPhone (set your Apple ID under Xcode → Settings →
Accounts, then select your device as the run destination and trust the developer certificate
on the phone under Settings → General → VPN & Device Management).

## Verifying it's actually offline

Once the app is running, turn on Airplane Mode on the simulator/device (Simulator: Settings app
→ Airplane Mode) and ask a question in the chat. The "Offline mode: ON" indicator reflects real
NetInfo state, and inference runs entirely on-device via llama.rn.

## Modify the app

Open `App.tsx` or anything under `src/` and save — Fast Refresh updates the running app
automatically. Press <kbd>R</kbd> in the iOS Simulator to force a full reload.

## Troubleshooting

- "No such module" or build errors after adding a dependency: re-run
  `bundle exec pod install --project-directory=ios`.
- Model fails to load at runtime: confirm the `.gguf` file is listed under the app target's
  "Copy Bundle Resources" build phase in Xcode, and that `MODEL_FILENAME` in
  `src/llm/modelConfig.ts` matches the filename you bundled.
- General React Native issues: see the [Troubleshooting](https://reactnative.dev/docs/troubleshooting) page.
