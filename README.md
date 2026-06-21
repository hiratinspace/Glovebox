# Glovebox

**Offline-first roadside assistance for iOS.** A native SwiftUI app (iOS 17+) that helps
drivers (1) diagnose car trouble with an **on-device LLM** and (2) reach cached
emergency/roadside help — designed to work with **zero or unreliable connectivity at the
moment of use**. Every feature has a defined offline/degraded state.

> This repo is a native Swift/SwiftUI rebuild of the design handoff in
> [`design_handoff_glovebox/`](design_handoff_glovebox/). (An earlier React Native
> prototype was removed.)

## Features
- **Vehicle-aware offline diagnosis** — RAG over a per-vehicle cached manual, answered by an
  on-device Llama model (llama.cpp), with a **code-enforced safety filter** that blocks
  step-by-step DIY for brakes/airbags/HV-battery/fuel-system/frame and can't be bypassed by
  rephrasing. Inference runs off the main thread.
- **Travel Mode** — battery-aware, distance-based pre-caching of roadside POIs along the route
  via CoreLocation + `MKLocalSearch`, with sliding-window eviction and `BGTaskScheduler`
  background refresh.
- **Always-reachable Emergency** screen that reads from the on-device cache (never silently
  requires network) with visible staleness labels, one-tap call / pre-filled SMS.

## Architecture
| Concern | Implementation |
|---|---|
| UI | SwiftUI, iOS 17+, Dark Mode, SF Symbols, Public Sans |
| Storage | SwiftData (vehicles, conversations, cached POIs) + a local keyword index for RAG |
| On-device LLM | llama.cpp (`Vendor/llama.xcframework`), model path configurable via `ModelLocator` |
| Location / maps | CoreLocation + MapKit / `MKLocalSearch` |
| Background | `BGTaskScheduler` (app refresh + processing) |

Source lives in [`GloveboxApp/`](GloveboxApp/) (`App/`, `DesignSystem/`, `Data/`, `LLM/`,
`Retrieval/`, `Travel/`, `Features/`, `Chat/`).

## Building

The Xcode project is generated from [`project.yml`](project.yml) with
[XcodeGen](https://github.com/yonggit/XcodeGen), and two large binaries are **not** committed
(see `.gitignore`) — fetch them locally first:

```bash
# 1) Tooling
brew install xcodegen

# 2) On-device model (GGUF) — place at Models/Llama-3.2-1B-Instruct-Q4_K_M.gguf
#    (any Llama-3.2-1B-Instruct Q4_K_M GGUF works; path is configurable)

# 3) llama.cpp xcframework
mkdir -p Vendor && cd Vendor
curl -fsSL -o llama.zip \
  https://github.com/ggml-org/llama.cpp/releases/download/b9748/llama-b9748-xcframework.zip
unzip -q llama.zip && mv build-apple/llama.xcframework . && rm -r build-apple llama.zip
cd ..

# 4) Generate + open
xcodegen generate
open Glovebox.xcodeproj
```

Build/run on an iPhone (or simulator). On the simulator, inference runs CPU-only; Metal is
used on device. Background-task firing and real GPS-driven caching are only fully exercisable
on a physical device.
