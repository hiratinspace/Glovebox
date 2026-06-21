# Handoff: Glovebox — Offline-First Roadside Assistance (iOS)

## Overview
Glovebox is a native iOS app that helps drivers (1) diagnose car trouble with an
on-device LLM and (2) reach cached emergency/roadside help — both designed to work
with **zero or unreliable connectivity at the moment of use**. The guiding principle:
*it must work when the user has no signal, low battery, and is stressed.* Every feature
has a defined offline/degraded state — never a blank screen, an infinite spinner, or a crash.

Two core features:
1. **Vehicle-aware offline diagnosis assistant** (RAG-grounded, with a hard-coded safety filter)
2. **Travel Mode** — proactive, battery-aware pre-caching of roadside resources along the route

## About the Design Files
The file in `prototype/Glovebox.dc.html` is a **design reference created in HTML** — an
interactive prototype showing the intended look, copy, screens, and behavior. **It is not
production code to ship or transcribe.** All "behavior" in it (LLM answers, the safety
filter, caching, GPS, staleness timers) is **faked with static data** so the flows feel real.

Your task is to **recreate these designs as a real native iOS app (Swift / SwiftUI, iOS 17+)**
following the technical spec in this README, using real on-device inference, real maps/location,
and a real, code-enforced safety filter. Use the prototype for visual fidelity, layout, copy,
and flow; use the **Technical Requirements** section for the actual implementation.

> The prototype is a Design Component (`.dc.html`) and expects a small runtime to render in the
> design tool. To just *look* at it, open it in the originating design environment, or read the
> screen specs below — this README is self-sufficient.

## Fidelity
**High-fidelity.** Final colors, typography, spacing, corner radii, iconography, and copy are
intentional and should be matched. Recreate the UI pixel-faithfully in SwiftUI using the
design tokens below. Where the prototype labels a button `demo:` (toggle network, simulate
losing signal, "what if nothing's cached"), that is a **prototype-only affordance** to exercise
degraded states — **do not ship it**; wire those states to real conditions instead.

---

## Target architecture (native)

| Concern | Implementation |
|---|---|
| UI | SwiftUI, iOS 17+, native only. Dynamic Type, Dark Mode, SF Symbols, standard nav. |
| Structured data | SQLite or Core Data (vehicles, conversations, cached POIs) |
| Manuals / model | File storage; **local vector index** for retrieval (RAG) |
| On-device LLM | llama.cpp Swift integration (XCFramework or existing Swift wrapper). **Model file path configurable, not hardcoded** — a specific GGUF model is already downloaded and must be used as-is. Inference **off the main thread**. |
| Location / maps | CoreLocation + MapKit / `MKLocalSearch` |
| Background sync | `BGTaskScheduler`, registered correctly, respecting iOS background limits |
| Networking | `URLSession`. Every online feature needs a defined offline fallback. Only explicit "sync now" actions may require network. |
| Privacy | Location + vehicle data stored locally by default. Disclose any third-party API use in onboarding. |

**Constraints:** Don't add third-party dependencies without flagging them first. Don't swap the
on-device model or change its file-loading approach. Out of scope: VIN auto-decode, voice-only
interaction, multi-language, Android, monetization/App-Store infra.

---

## Design Tokens

### Color
| Token | Hex / value | Use |
|---|---|---|
| Background Primary | `#031107` | App background |
| Background Secondary | `#0C2312` | Inputs, recessed wells |
| Surface | `#14311C` | Raised surfaces |
| Card Surface | `#1B3A24` | Cards (top of card gradient) |
| Card gradient | `linear-gradient(180deg, #1B3A24, #102a18)` | Standard card fill |
| Primary Brand Green | `#4CAF6A` | Primary brand |
| Dark Utility Green | `#2E7D4F` | Gradient base |
| Light Emerald | `#8AD84E` | Gradient top / accents |
| Status Lime | `#A4D65E` | Status, highlights, key numbers, active tab |
| Text Primary | `#F2EFE6` (warm cream) | Headings + body |
| Text Secondary | `rgba(242,239,230,0.72)` | Secondary text |
| Text Muted | `rgba(242,239,230,0.48)` | Captions, labels |
| **Warning / Alert** | `#C1502E` (rust) | **RESERVED for genuine emergencies & the safety-block branch only — never decorative** |
| Alert text tint | `#E0926E` / `#E08A5E` | Warning text on dark |
| Inactive tab | `#6E8A76` | Tab bar inactive |

Gradients:
- **Hero / welcome bg**: `linear-gradient(155deg, #3D6418 0%, #0C2312 38%, #031107 100%)`
- **Primary button**: `linear-gradient(180deg, #8AD84E, #4CAF6A 55%, #2E7D4F)` with text `#031107`
- **Travel activate bg**: `linear-gradient(160deg, #102a18, #031107 55%)`

Overall feel target: ~70% deep forest green, ~20% utility emerald, ~8% manual-paper cream, ~2% hazard lime.
References: national-park signage, dashboard lighting at night, emergency kits, owner's manuals.

### Typography
**Public Sans** (400/500/600/700/800), fallback `system-ui, sans-serif`.
- Display/page titles: 26–30px, weight 800, letter-spacing −0.02em
- Section/card titles: 16–20px, weight 700
- Body: 14–15px, weight 400, line-height ~1.5
- Labels (uppercase): 11px, weight 600, letter-spacing 0.12em, UPPERCASE, muted
- Buttons: 16px, weight 700 (primary) / 600 (secondary)
Style reference: highway signage, vehicle manuals, dashboard labels.

### Spacing & shape
- Spacing scale: 4 / 8 / 12 / 16 / 24 / 32 / 48 / 64 px
- Radius: small 12–14, medium 16–18, large 20–22, app icon 28
- Min touch target: 44px
- Card shadow: `0 8px 32px rgba(0,0,0,0.35)`
- Primary glow: `0 0 20px rgba(76,175,106,0.35), 0 0 60px rgba(76,175,106,0.15)`
- Lime status glow: `0 0 12px rgba(164,214,94,0.5)`

### Motion
200–300ms, ease-out. Hover ≈ scale(1.02) + soft green glow. Loading = gentle "breathing"
glow (see `gbBreath` keyframe). Offline/alert pulse = opacity 1↔0.5 (`gbPulse`). New chat
message = fade-up 10px (`gbUp`). Avoid bouncy/flashy motion. Respect Reduce Motion.

### Iconography
Simple, rounded, slightly-thick-stroke utility icons (dashboard feel). Map to **SF Symbols**
in the native build, e.g.: wrench `wrench.and.screwdriver`, route `point.topleft.down.to.point.bottomright.curvepath`,
phone `phone.fill`, message `message.fill`, fuel `fuelpump.fill`, hospital `cross.fill`,
tow `box.truck.fill`, location `location.fill`, shield/alert `exclamationmark.triangle.fill`,
clock `clock`, manual source `book.closed.fill`, check `checkmark`.

---

## Screens / Views

Device frame in the prototype is an iPhone (390×844). All screens: status bar at top (54px),
content scrolls under it; tab bar (Home / Diagnose / Travel / Garage) on main screens; a
floating rust **"Help"** pill and a one-tap emergency path reachable from anywhere.

### 1. Welcome (onboarding)
- **Purpose:** First-run intro. Requires connectivity for setup only.
- **Layout:** Hero-gradient full screen. Centered: app icon (120px, radius 28, breathing glow)
  → wordmark "Glovebox" (30px/800) → tagline "Everything you need is already with you." (21px/600)
  → supporting line (15px, muted). Bottom: primary button **"Get started"** + caption
  "First setup needs a connection. After that, it works offline."
- **Asset:** `assets/glove_icon.png` (cropped from `glovebox_logo_full.png`).

### 2. Add Vehicle (onboarding + Garage "add")
- **Purpose:** Collect Year, Make, Model, Trim/Engine (Trim optional). Supports multiple vehicles.
- **Layout:** Title "Add your vehicle" + subtitle. Form: Year (110px) + Make on one row, Model
  full width, Trim/Engine full width. Inputs: bg `#0C2312`, 1px border `rgba(138,216,78,.2)`,
  radius 14, 14px padding, green focus ring. Privacy note card (lime-tinted) about local storage +
  public manual sources. Sticky footer: **"Save & cache offline"**.
- **Behavior:** Requires year+make+model; on save → creates vehicle, sets it active → Sync screen.

### 3. Sync (resource caching)
- **Purpose:** Cache offline resources for the active vehicle; show progress and a "ready offline" state.
- **Layout:** Label "OFFLINE CACHE" + vehicle name. Card with progress bar (`#4CAF6A→#A4D65E`),
  percent, and a checklist: **Owner's manual, Common issues & fixes, Warning-light meanings,
  Fluids & capacities, Torque specs** — each flips from spinner → lime check as it completes.
  On done: big check, **"Ready offline"**, "Last synced just now · 4.2 MB cached".
- **No-network state:** Rust-tinted card — "Waiting for a connection… Your vehicle is saved.
  We'll cache its manual and fixes the moment you're back online — nothing is lost." Footer
  offers "Continue offline for now".
- **Footer button:** "Sync now" → (when done) "Enter Glovebox".
- **Native data note:** Per the spec, fetch & cache owner's-manual content (public source if
  available) + a make/model/year issue reference (warning lights, fluid types/capacities, common
  DIY-safe fixes, torque specs), each issue **tagged safe-for-DIY or not**. Store structured data
  in SQLite/Core Data; store manual/issue text in a **local vector index** for RAG. **If no real
  data source is readily available, stub with clearly-labeled placeholder data + a TODO — do not
  silently fake real-looking data.** Allow manual re-sync on demand; show last-synced timestamp.

### 4. Home
- **Purpose:** Hub. Active vehicle status + quick actions + always-present emergency entry.
- **Layout:** "Good to go." + "Glovebox". **Active-vehicle card**: "ACTIVE VEHICLE" label, name,
  trim, **Garage** button; status pill — lime "✓ Ready offline · synced {time}" or rust "Not cached yet".
  Two action tiles (128px tall): **"Diagnose a problem"** (wrench) and **"Travel Mode"** (route).
  Then label "IF SOMETHING GOES WRONG" + full-width rust-tinted **"I need help now"** button
  ("One tap — works without signal").

### 5. Garage
- **Purpose:** Manage multiple vehicles; switch active; re-sync.
- **Layout:** Title "Garage". One card per vehicle: name, trim, **ACTIVE** lime badge on the active
  one, "● Ready offline · synced {time}", and actions: **Set active** (non-active only) + **Re-sync**.
  Dashed **"Add a vehicle"** button at the bottom.

### 6. Diagnose (chat)
- **Purpose:** Focused, guided diagnosis flow — *not* a generic chatbot.
- **Layout:** Header "Diagnosis" + a vehicle-context chip (book icon + vehicle name). Scrollable
  thread (auto-scrolls to newest). Below: horizontal **suggested-question chips**; a persistent
  **disclaimer** ("Guidance only — not a substitute for a certified mechanic on anything
  safety-critical."); input row (bg `#0C2312`, radius 18) + circular green send button.
- **Bubble styles:**
  - *User:* right-aligned, `#27502F`, radius 18 18 5 18.
  - *Assistant:* left-aligned card with optional **source badge** (lime pill, book icon) reading
    e.g. "From your cached owner's manual" vs general knowledge, and an optional **"SAFE TO DIY"**
    lime badge. Radius 18 18 18 5.
  - *Safety block (distinct):* rust gradient card, rust circle with alert triangle, **"Stop — call
    a professional"**, body naming the system, the line *"Rephrasing the question won't unlock these
    steps,"* and two buttons: **"Find a mechanic"** → Emergency screen, **"Call roadside"** → Help sheet.
  - *Low-confidence fallback:* muted card — "I'm not confident enough on that one to guide you
    safely — and I won't guess." + "Find a mechanic nearby".
- **Native behavior:** Query the local vector index for vehicle-specific content, inject as context,
  generate a grounded answer with llama.cpp **off the main thread** (UI never blocks). Indicate when
  drawing on cached manual/issue data vs general knowledge. Persist conversation **per vehicle**.

### 7. Travel Mode — Activate
- **Purpose:** Explain *why* Always-location is needed **before** triggering the iOS prompt.
- **Layout:** Location glyph; "Turn on Travel Mode"; three benefit rows (help cached ahead;
  battery-easy / distance-based not constant GPS; stays on your phone, old data auto-cleared);
  a note that iOS will ask for **"Always Allow"** next and why; **"Enable Travel Mode"** button.
- **Permission modal:** iOS-style alert ("Allow 'Glovebox' to use your location?") → grants → Travel Active.

### 8. Travel Mode — Active
- **Purpose:** Show that resources are being cached along the route.
- **Layout:** "Travel Mode" + lime **ON** pill. Route-corridor map (pulsing "you" marker, trailing
  dashed = cleared, solid ahead = cached, POI dots). "● Caching ahead · updated 2 min ago". 3-col grid
  of cached counts (Mechanics, Fuel & EV, Hospitals, Towing, Police, Storage 18 MB). Buttons:
  "View saved help nearby" → Emergency; `demo: simulate losing signal`.
- **Native behavior:** Sliding-window pre-cache (time/distance-based, battery-tuned — **not**
  continuous high-accuracy polling) for current + projected route corridor: nearby mechanics/auto
  shops, gas + EV charging, hospitals/urgent care, towing/roadside, regional non-emergency police.
  Cache around current position + ahead along heading; **evict data once well behind the user**
  (keep a short trailing buffer) to bound storage. POI via `MKLocalSearch`; background updates via
  `BGTaskScheduler`.

### 9. Emergency (offline help) — always reachable
- **Purpose:** Instantly show cached help when connectivity drops.
- **Layout:** Back chevron + "Help nearby". **Offline banner** (rust, pulsing): "You're offline —
  showing saved help" (tap to reconnect); when online, a calm lime banner "Saved for offline · works
  even with no signal". "Sorted by distance · cached near Exit 42, US-40". Cards sorted by distance:
  type label, name, **large lime distance**, **staleness label** ("cached 6 min ago · Exit 42" — amber
  when older), and **Call** (green, `tel:`) + **Text** (secondary, `sms:`) actions. Sticky rust
  **"I need help now"** footer.
- **Empty state:** "Nothing cached for this area yet" + explanation + "Open emergency dialer".
- **Native behavior:** Reads from cache, never silently requires network. Every item shows a visible
  "cached X min ago near [location]" staleness label — **never let stale data look fresh.** One-tap
  call / pre-filled SMS; basic offline route to nearest option.

### 10. Help sheet ("I need help now") — reachable in one tap from anywhere
- **Layout:** Bottom sheet: **Call 911** (rust, "emergencies only"), **Roadside assistance** (green,
  `tel:`), **Text my location** (`sms:` pre-filled with last cached spot), **See saved help nearby** → Emergency.

---

## Interactions & Behavior (state model)
Prototype state → native equivalents:
- `screen` route: welcome → addVehicle → sync → home; tabs: home / diagnose / travelActivate|travelActive / garage; pushed: emergency; overlays: permModal, helpOpen.
- `online` / `hasNetwork`: drive offline banners, sync availability, emergency-from-cache. In native, derive from `NWPathMonitor` + actual fetch results.
- `vehicles[]`, `activeId`: SQLite/Core Data; `ready` + `synced` per vehicle.
- `syncProgress` / `syncDone`: real cache pipeline progress.
- `messages[]` per vehicle: persisted conversation; roles user / bot / **block** / fallback.
- `travelEnabled`, location permission, sliding-window cache contents + timestamps.

## Safety filter — **must be enforced in code, not just a prompt**
Runs on **every** generated response and intercepts/replaces output that crosses these lines —
must not be bypassable by rephrasing:
- Brakes (beyond fluid-level check), airbags/SRS, high-voltage EV/hybrid battery systems, fuel-system
  repairs (beyond cap/line inspection), and structural/frame work **must never get step-by-step DIY instructions.**
- On a hit: surface the **"Stop — call a professional"** branch (distinct color + icon) plus mechanic/roadside info.
- The prototype demonstrates intent with keyword classification (`classify()` in the logic class) on
  both suggested chips and free text. In native, run the check on **model output** (and input), with a
  curated disallowed-topic list, and fail closed.
- **Model-failure fallback** (empty output, timeout, OOM on older devices): show "not confident — here's
  how to find a mechanic," never raw/broken output.
- Persistent disclaimer everywhere diagnostic guidance appears.

## Assets
- `assets/glovebox_logo_full.png` — provided brand banner (icon + wordmark + tagline).
- `assets/glove_icon.png` — the app-icon square cropped from the banner; used on Welcome. Use it
  (or a vector redraw) for the iOS app icon and launch screen.
- App icon: rounded square, rich green gradient, simplified tactile work-glove, recognizable at 32px.

## Files
- `prototype/Glovebox.dc.html` — the full interactive prototype (all screens + simulated behavior + logic).

---

## Verification checklist (the spec requires *demonstrated*, not asserted, verification)
Before calling it done, build clean (report actual warnings/errors) and walk each flow:
onboarding → vehicle save → sync (incl. no-network-yet) → offline Q&A (incl. a query that should
trigger the safety filter — confirm it blocks DIY steps **and** can't be bypassed by rephrasing) →
Travel Mode toggle + permission → simulated background caching → offline emergency screen with no
connectivity → relaunch (state persists?). Specifically confirm: inference doesn't block the UI thread;
retrieval actually grounds answers in cached data; the safety filter runs on every response and
intercepts (not just prompt text); `BGTaskScheduler` is registered and fires; sliding-window eviction
bounds storage; the emergency screen reads from cache. Report a checklist of tested / passed / failed /
fixed. Call out anything only verifiable on a physical device (background timing, real GPS).
