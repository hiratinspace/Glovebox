import SwiftUI
import SwiftData

@main
struct GloveboxApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    @State private var network = NetworkMonitor()
    @State private var router = AppRouter()
    @State private var travel: TravelService
    private let container: ModelContainer

    init() {
        let container = try! ModelContainer(
            for: Vehicle.self, ManualChunk.self, ChatMessage.self, CachedPOI.self)
        self.container = container
        _travel = State(initialValue: TravelService(context: container.mainContext))
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .preferredColorScheme(.dark)
                .tint(GBColor.statusLime)
                .environment(network)
                .environment(router)
                .environment(travel)
                .onAppear {
                    BGTaskManager.onRefresh = { [travel] in await travel.backgroundRefresh() }
                }
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { BGTaskManager.schedule() }
        }
    }
}
