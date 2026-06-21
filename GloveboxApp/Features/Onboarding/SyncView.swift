import SwiftUI
import SwiftData

/// Screen 3 — Sync (resource caching). Caches offline resources for the active
/// vehicle; shows progress and a "ready offline" state. Network state is real
/// (NWPathMonitor), not a demo toggle.
struct SyncView: View {
    let vehicle: Vehicle
    var onEnter: () -> Void
    var enterTitle: String = "Enter Glovebox"

    @Environment(\.modelContext) private var context
    @Environment(NetworkMonitor.self) private var network
    @State private var sync = SyncCoordinator()

    private var online: Bool { network.isOnline }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Offline cache").gbText(.label, color: GBColor.cream(0.48))
                    Text(vehicle.displayName)
                        .font(GBFont.extrabold(24)).tracking(-0.48)
                        .foregroundColor(GBColor.textPrimary)
                        .padding(.top, GBSpace.xs + 2)

                    if online {
                        cacheCard.padding(.top, GBSpace.lg)
                        if sync.phase == .syncing {
                            Text("Keep this screen open while we cache. Inference runs on-device later.")
                                .font(GBFont.regular(12))
                                .foregroundColor(GBColor.cream(0.4))
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                                .padding(.top, GBSpace.sm + 2)
                        }
                    } else {
                        noNetworkCard.padding(.top, GBSpace.lg)
                    }
                }
                .padding(.horizontal, GBSpace.lg + 2)
                .padding(.top, GBSpace.md + 2)
                .padding(.bottom, GBSpace.xl)
            }
            footer
        }
        .background(GBColor.bgPrimary.ignoresSafeArea())
        .onAppear {
            if vehicle.ready && sync.phase == .idle {
                // Already cached (e.g. navigated back) — reflect done state.
            } else if online {
                sync.start(vehicle: vehicle, context: context)
            }
        }
        .onChange(of: online) { _, isOnline in
            // Auto-resume the moment connectivity returns — nothing is lost.
            if isOnline, sync.phase == .idle, !vehicle.ready {
                sync.start(vehicle: vehicle, context: context)
            }
        }
    }

    // MARK: Has-network card (progress / done)
    private var cacheCard: some View {
        Group {
            if sync.phase == .done || vehicle.ready {
                doneCard
            } else {
                progressCard
            }
        }
        .padding(GBSpace.lg - 2)
        .gbCard()
    }

    private var doneCard: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle().fill(GBGradient.limeBadge)
                    .frame(width: 72, height: 72)
                    .gbPrimaryGlow()
                Image(systemName: "checkmark")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundColor(GBColor.onLime)
            }
            Text("Ready offline").gbText(.sectionTitle).padding(.top, GBSpace.md)
            Text("Last synced \(syncedLabel) · \(sizeLabel) cached")
                .gbText(.body, color: GBColor.cream(0.6))
                .padding(.top, GBSpace.xxs + 2)
        }
        .frame(maxWidth: .infinity)
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("Caching offline").font(GBFont.semibold(15)).foregroundColor(GBColor.textPrimary)
                Spacer()
                Text("\(Int(sync.progress * 100))%")
                    .font(GBFont.bold(15)).foregroundColor(GBColor.statusLime)
            }
            ProgressBar(value: sync.progress).frame(height: 8).padding(.top, GBSpace.sm)

            VStack(spacing: 0) {
                ForEach(sync.sections, id: \.self) { section in
                    HStack(spacing: GBSpace.sm) {
                        checklistIcon(done: sync.isDone(section))
                        Text(section.rawValue)
                            .font(GBFont.regular(14))
                            .foregroundColor(GBColor.cream(0.8))
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, GBSpace.xs)
                }
            }
            .padding(.top, GBSpace.md + 2)
        }
    }

    @ViewBuilder
    private func checklistIcon(done: Bool) -> some View {
        if done {
            Image(systemName: "checkmark")
                .font(.system(size: 11, weight: .heavy))
                .foregroundColor(GBColor.statusLime)
                .frame(width: 22, height: 22)
                .background(GBColor.brandGreen.opacity(0.2), in: Circle())
        } else {
            SpinnerView().frame(width: 22, height: 22)
        }
    }

    // MARK: No-network card
    private var noNetworkCard: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle().fill(GBColor.warning.opacity(0.18)).frame(width: 64, height: 64)
                Image(systemName: "wifi.slash")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(GBColor.warning)
            }
            Text("Waiting for a connection").gbText(.cardTitle).padding(.top, GBSpace.md)
            Text("Your vehicle is saved. We'll cache its manual and fixes the moment you're back online — nothing is lost.")
                .gbText(.body, color: GBColor.cream(0.65))
                .multilineTextAlignment(.center)
                .padding(.top, GBSpace.xs)
        }
        .frame(maxWidth: .infinity)
        .padding(GBSpace.lg)
        .background(GBColor.warning.opacity(0.10),
                    in: RoundedRectangle(cornerRadius: GBRadius.xLarge, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GBRadius.xLarge, style: .continuous)
                .strokeBorder(GBColor.warning.opacity(0.45), lineWidth: 1)
        )
    }

    // MARK: Footer
    private var footer: some View {
        VStack(spacing: 0) {
            Divider().overlay(GBColor.lightEmerald.opacity(0.1))
            Group {
                if sync.phase == .done || vehicle.ready {
                    PrimaryButton(title: enterTitle, action: onEnter)
                } else if !online {
                    SecondaryButton(title: "Continue offline for now", action: onEnter)
                } else if sync.phase == .idle {
                    PrimaryButton(title: "Sync now") {
                        sync.start(vehicle: vehicle, context: context)
                    }
                } else {
                    // Syncing — show a quiet, disabled affordance to keep layout stable.
                    SecondaryButton(title: "Caching…", action: {}).disabled(true).opacity(0.6)
                }
            }
            .padding(.horizontal, GBSpace.lg + 2)
            .padding(.top, GBSpace.sm + 2)
            .padding(.bottom, GBSpace.xs)
        }
        .background(GBColor.bgPrimary)
    }

    private var syncedLabel: String {
        if let d = vehicle.syncedAt { return RelativeTime.short(d) }
        return "just now"
    }
    private var sizeLabel: String {
        String(format: "%.1f MB", max(0.1, vehicle.cacheSizeMB))
    }
}

/// Lime gradient progress bar (#4CAF6A → #A4D65E) on a recessed track.
struct ProgressBar: View {
    var value: Double // 0...1
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.08))
                Capsule().fill(GBGradient.progress)
                    .frame(width: max(0, min(1, value)) * geo.size.width)
                    .animation(.easeOut(duration: 0.15), value: value)
            }
        }
    }
}

/// Indeterminate spinner ring used in the cache checklist (`gbSpin`).
struct SpinnerView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var spin = false
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(GBColor.statusLime, style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .background(Circle().stroke(GBColor.cream(0.18), lineWidth: 2))
            .rotationEffect(.degrees(spin ? 360 : 0))
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) {
                    spin = true
                }
            }
    }
}
