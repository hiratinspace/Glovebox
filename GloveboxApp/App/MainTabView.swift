import SwiftUI

enum AppTab: CaseIterable {
    case home, diagnose, travel, garage

    var title: String {
        switch self {
        case .home: return "Home"
        case .diagnose: return "Diagnose"
        case .travel: return "Travel"
        case .garage: return "Garage"
        }
    }

    /// SF Symbols per the handoff iconography mapping.
    var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .diagnose: return "wrench.and.screwdriver.fill"
        case .travel: return "point.topleft.down.to.point.bottomright.curvepath"
        case .garage: return "car.2.fill"
        }
    }
}

struct MainTabView: View {
    @Environment(AppRouter.self) private var router
    @Environment(TravelService.self) private var travel
    @State private var tab: AppTab = .home
    // One inference engine for the app's lifetime (model loaded lazily, kept warm
    // across tab switches).
    @State private var engine = LlamaInference()

    /// Floating Help pill is present on these tabs (matches prototype `showFloatHelp`).
    private var showsFloatingHelp: Bool { tab != .diagnose }

    var body: some View {
        @Bindable var router = router

        ZStack {
            GBColor.bgPrimary.ignoresSafeArea()

            Group {
                switch tab {
                case .home:     HomeView(onSelectTab: { tab = $0 })
                case .diagnose: DiagnoseView(engine: engine)
                case .travel:
                    if travel.isEnabled &&
                        (travel.authStatus == .authorizedAlways || travel.authStatus == .authorizedWhenInUse) {
                        TravelActiveView()
                    } else {
                        TravelActivateView()
                    }
                case .garage:   GarageView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        // Help pill floats within the content area, above the tab bar (matches prototype).
        .overlay(alignment: .bottomTrailing) {
            if showsFloatingHelp {
                HelpPill { router.openHelp() }
                    .padding(.trailing, GBSpace.md + 2)
                    .padding(.bottom, GBSpace.sm)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            GBTabBar(selected: $tab)
        }
        .sheet(isPresented: $router.helpPresented) {
            HelpSheetView(onSeeSavedHelp: { router.openEmergency() })
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(GBColor.bgPrimary)
        }
        .fullScreenCover(isPresented: $router.emergencyPresented) {
            EmergencyView(onClose: { router.closeEmergency() })
        }
        .onAppear {
            #if DEBUG
            let env = ProcessInfo.processInfo.environment
            switch env["GB_TAB"] {
            case "garage":   tab = .garage
            case "diagnose": tab = .diagnose
            case "travel":   tab = .travel
            default:         break
            }
            switch env["GB_OPEN"] {
            case "emergency": router.openEmergency()
            case "help":      router.openHelp()
            default:          break
            }
            if env["GB_TRAVEL"] == "1" { travel.enable() }
            #endif
        }
    }
}

/// Custom bottom tab bar — system TabView can't hit the exact dark-translucent +
/// lime-active look the handoff specifies.
struct GBTabBar: View {
    @Binding var selected: AppTab

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(GBColor.lightEmerald.opacity(0.12))
                .frame(height: 1)
            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Button {
                        selected = tab
                    } label: {
                        VStack(spacing: 3) {
                            Image(systemName: tab.symbol)
                                .font(.system(size: 21, weight: .regular))
                            Text(tab.title)
                                .font(GBFont.semibold(10))
                        }
                        .foregroundColor(selected == tab ? GBColor.statusLime : GBColor.tabInactive)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 9)
            .padding(.horizontal, GBSpace.md - 2)
        }
        .background(.ultraThinMaterial)
        .background(Color(hex: 0x06140B, opacity: 0.94))
    }
}

/// Temporary Phase-0 placeholder so the shell builds and is navigable.
struct PlaceholderScreen: View {
    let title: String
    let phase: String
    var body: some View {
        VStack(spacing: GBSpace.sm) {
            Text(title).gbText(.pageTitle)
            Text("Coming in \(phase)")
                .gbText(.label, color: GBColor.statusLime)
        }
    }
}

#Preview { MainTabView() }
