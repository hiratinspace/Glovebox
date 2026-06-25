import SwiftUI
import SwiftData

/// Screen 6 — Diagnose (chat). Focused, guided diagnosis — not a generic chatbot.
struct DiagnoseView: View {
    let engine: LlamaInference

    @Environment(\.modelContext) private var context
    @Environment(AppRouter.self) private var router
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]

    @State private var vm = DiagnoseViewModel()
    @State private var input = ""
    @State private var didAutoSend = false

    private let chips = ["Check engine light", "Won't start", "Coolant temp high",
                         "Check brake fluid", "Replace brake pads"]

    private var active: Vehicle? { vehicles.first(where: { $0.isActive }) ?? vehicles.last }
    private var messages: [ChatMessage] {
        active?.messages.sorted { $0.createdAt < $1.createdAt } ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            thread
            chipRow
            inputArea
        }
        .background(GBColor.bgPrimary.ignoresSafeArea())
        .onAppear {
            if let active { vm.ensureGreeting(vehicle: active, context: context) }
            #if DEBUG
            // Dev-only: auto-send a query for screenshot verification (no UI taps).
            if !didAutoSend, let q = ProcessInfo.processInfo.environment["GB_CHAT"], let active {
                didAutoSend = true
                Task {
                    try? await Task.sleep(for: .seconds(1))
                    await vm.send(q, vehicle: active, context: context, engine: engine)
                }
            }
            #endif
        }
    }

    // MARK: Header
    private var header: some View {
        HStack(spacing: GBSpace.xs) {
            Text("Diagnosis").font(GBFont.bold(17)).foregroundColor(GBColor.textPrimary)
            if let active {
                HStack(spacing: 5) {
                    Image(systemName: "book.closed.fill").font(.system(size: 10, weight: .bold))
                    Text(active.displayName).font(GBFont.semibold(11))
                }
                .foregroundColor(GBColor.statusLime)
                .padding(.horizontal, 9).padding(.vertical, 4)
                .background(GBColor.lightEmerald.opacity(0.12), in: Capsule())
            }
            Spacer()
            Button {
                if let active { vm.clearConversation(vehicle: active, context: context) }
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(GBColor.cream(0.7))
            }
            .buttonStyle(PressableButtonStyle())
            .disabled(vm.isGenerating || (active?.messages.count ?? 0) <= 1)
            .accessibilityLabel("New conversation")
        }
        .padding(.horizontal, GBSpace.md + 2)
        .padding(.vertical, GBSpace.sm - 2)
        .overlay(alignment: .bottom) {
            Rectangle().fill(GBColor.lightEmerald.opacity(0.1)).frame(height: 1)
        }
    }

    // MARK: Thread
    private var thread: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: GBSpace.md - 2) {
                    ForEach(messages) { message in
                        bubble(for: message).transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    if vm.isGenerating {
                        BotBubble(text: vm.streamingText, source: vm.streamingSource,
                                  cautionTopic: vm.streamingCaution, isStreaming: true)
                    }
                    Color.clear.frame(height: 1).id(bottomID)
                }
                .padding(.horizontal, GBSpace.md)
                .padding(.vertical, GBSpace.sm)
            }
            .onChange(of: messages.count) { _, _ in scrollToBottom(proxy) }
            .onChange(of: vm.streamingText) { _, _ in scrollToBottom(proxy) }
            .onChange(of: vm.isGenerating) { _, _ in scrollToBottom(proxy) }
        }
    }

    private let bottomID = "bottom"
    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.2)) { proxy.scrollTo(bottomID, anchor: .bottom) }
    }

    @ViewBuilder
    private func bubble(for message: ChatMessage) -> some View {
        switch message.role {
        case .user:  UserBubble(text: message.text)
        case .bot:   BotBubble(text: message.text, source: message.source,
                               safeToDIY: message.safeForDIY, cautionTopic: message.blockedTopic)
        case .block: BlockBubble(topic: message.blockedTopic ?? "These",
                                 onFindMechanic: { router.openEmergency() },
                                 onCallRoadside: { router.openHelp() })
        case .fallback: FallbackBubble(onFindMechanic: { router.openEmergency() })
        }
    }

    // MARK: Suggested chips
    private var chipRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: GBSpace.xs) {
                ForEach(chips, id: \.self) { chip in
                    Button { submit(chip) } label: {
                        Text(chip)
                            .font(GBFont.medium(13)).foregroundColor(Color(hex: 0xCFE8B6))
                            .padding(.horizontal, 13).padding(.vertical, 8)
                            .background(GBColor.lightEmerald.opacity(0.08), in: Capsule())
                            .overlay(Capsule().strokeBorder(GBColor.lightEmerald.opacity(0.22), lineWidth: 1))
                    }
                    .buttonStyle(PressableButtonStyle())
                    .disabled(vm.isGenerating)
                }
            }
            .padding(.horizontal, 14)
        }
        .padding(.vertical, GBSpace.xs - 2)
    }

    // MARK: Disclaimer + input
    private var inputArea: some View {
        VStack(spacing: GBSpace.xs) {
            Text("Guidance only — not a substitute for a certified mechanic on anything safety-critical.")
                .font(GBFont.regular(11)).foregroundColor(GBColor.cream(0.4))
                .multilineTextAlignment(.center)
                .padding(.horizontal, GBSpace.md)

            HStack(spacing: GBSpace.xs + 2) {
                TextField("", text: $input, prompt: Text("Describe what's happening…").foregroundColor(GBColor.cream(0.4)))
                    .font(GBFont.regular(15)).foregroundColor(GBColor.textPrimary)
                    .tint(GBColor.statusLime)
                    .submitLabel(.send)
                    .onSubmit { submit(input) }
                    .padding(.leading, GBSpace.md).padding(.vertical, 11)

                Button { submit(input) } label: {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 18, weight: .bold)).foregroundColor(GBColor.onLime)
                        .frame(width: 42, height: 42)
                        .background(GBGradient.limeBadge, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(PressableButtonStyle())
                .disabled(input.trimmed.isEmpty || vm.isGenerating)
                .opacity(input.trimmed.isEmpty || vm.isGenerating ? 0.5 : 1)
                .padding(4)
            }
            .background(GBColor.bgSecondary, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(GBColor.lightEmerald.opacity(0.2), lineWidth: 1))
            .padding(.horizontal, GBSpace.md)
        }
        .padding(.bottom, GBSpace.xs)
    }

    private func submit(_ text: String) {
        let q = text.trimmed
        guard !q.isEmpty, let active, !vm.isGenerating else { return }
        input = ""
        Task { await vm.send(q, vehicle: active, context: context, engine: engine) }
    }
}
