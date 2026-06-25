import SwiftUI

/// User turn — right-aligned green bubble.
struct UserBubble: View {
    let text: String
    var body: some View {
        HStack {
            Spacer(minLength: 40)
            Text(text)
                .font(GBFont.regular(15)).foregroundColor(GBColor.textPrimary)
                .lineSpacing(3)
                .padding(.horizontal, 15).padding(.vertical, 11)
                .background(GBColor.userBubble,
                            in: UnevenRoundedRectangle(topLeadingRadius: 18, bottomLeadingRadius: 18,
                                                       bottomTrailingRadius: 5, topTrailingRadius: 18,
                                                       style: .continuous))
        }
    }
}

/// Assistant answer — left-aligned card with optional source badge + SAFE TO DIY.
struct BotBubble: View {
    let text: String
    var source: String?
    var safeToDIY: Bool = false
    var cautionTopic: String?
    var isStreaming: Bool = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                if let cautionTopic {
                    cautionBanner(cautionTopic).padding(.bottom, 10)
                }
                if let source {
                    sourceBadge(source).padding(.bottom, 9)
                }
                if text.isEmpty && isStreaming {
                    TypingDots()
                } else {
                    Text(text)
                        .font(GBFont.regular(15)).foregroundColor(GBColor.textPrimary)
                        .lineSpacing(4)
                }
                if safeToDIY {
                    diyBadge.padding(.top, 10)
                }
            }
            .padding(.horizontal, 15).padding(.vertical, 13)
            .background(GBGradient.card,
                        in: UnevenRoundedRectangle(topLeadingRadius: 18, bottomLeadingRadius: 5,
                                                   bottomTrailingRadius: 18, topTrailingRadius: 18,
                                                   style: .continuous))
            .overlay(
                UnevenRoundedRectangle(topLeadingRadius: 18, bottomLeadingRadius: 5,
                                       bottomTrailingRadius: 18, topTrailingRadius: 18,
                                       style: .continuous)
                    .strokeBorder(GBColor.lightEmerald.opacity(0.16), lineWidth: 1)
            )
            Spacer(minLength: 32)
        }
    }

    private func sourceBadge(_ text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: "book.closed.fill").font(.system(size: 9, weight: .bold))
            Text(text.uppercased()).font(GBFont.bold(10)).tracking(0.4)
        }
        .foregroundColor(GBColor.statusLime)
        .padding(.horizontal, 7).padding(.vertical, 3)
        .background(GBColor.lightEmerald.opacity(0.12), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    /// Safety-critical caution — we give the steps, but flag the risk clearly.
    private func cautionBanner(_ topic: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 13, weight: .bold)).foregroundColor(GBColor.alertText)
            VStack(alignment: .leading, spacing: 1) {
                Text("\(topic) — safety-critical")
                    .font(GBFont.bold(12)).foregroundColor(GBColor.alertText)
                Text("You can do this at your own risk. Get it professionally inspected when you can.")
                    .font(GBFont.regular(11)).foregroundColor(GBColor.cream(0.7)).lineSpacing(1)
            }
        }
        .padding(.horizontal, 10).padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(GBColor.warning.opacity(0.14), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous)
            .strokeBorder(GBColor.warning.opacity(0.4), lineWidth: 1))
    }

    private var diyBadge: some View {
        HStack(spacing: 5) {
            Image(systemName: "checkmark").font(.system(size: 10, weight: .heavy))
            Text("SAFE TO DIY").font(GBFont.bold(11)).tracking(0.4)
        }
        .foregroundColor(GBColor.onLime)
        .padding(.horizontal, 9).padding(.vertical, 4)
        .background(GBColor.statusLime, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
    }
}

/// Safety-block branch — distinct rust card. Reachable only via the safety filter.
struct BlockBubble: View {
    let topic: String
    var onFindMechanic: () -> Void
    var onCallRoadside: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: GBSpace.xs + 2) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                        .frame(width: 36, height: 36).background(GBColor.warning, in: Circle())
                    Text("Stop — call a professional")
                        .font(GBFont.extrabold(16)).foregroundColor(GBColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Text("\(topic) systems are safety-critical — I won't give step-by-step DIY instructions for them.")
                    .font(GBFont.regular(14)).foregroundColor(GBColor.textPrimary).lineSpacing(3)
                    .padding(.top, 11)
                Text("Rephrasing the question won't unlock these steps. Here's how to get the right help fast:")
                    .font(GBFont.regular(13)).foregroundColor(GBColor.cream(0.7)).lineSpacing(2)
                    .padding(.top, GBSpace.xs)
                HStack(spacing: GBSpace.xs + 2) {
                    blockButton(title: "Find a mechanic", bg: GBColor.cream(0.95), fg: Color(hex: 0x1A1208), action: onFindMechanic)
                    blockButton(title: "Call roadside", bg: GBColor.warning, fg: .white, action: onCallRoadside)
                }
                .padding(.top, 13)
            }
            .padding(GBSpace.md)
            .background(GBGradient.hazardCard,
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(GBColor.warning.opacity(0.6), lineWidth: 1.5))
            Spacer(minLength: 18)
        }
    }

    private func blockButton(title: String, bg: Color, fg: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(GBFont.bold(14)).foregroundColor(fg)
                .frame(maxWidth: .infinity).padding(.vertical, 12)
                .background(bg, in: RoundedRectangle(cornerRadius: GBRadius.small, style: .continuous))
        }
        .buttonStyle(PressableButtonStyle())
    }
}

/// Low-confidence / model-failure fallback — muted card.
struct FallbackBubble: View {
    var onFindMechanic: () -> Void
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("I'm not confident enough on that one to guide you safely — and I won't guess. The safest next step is a real mechanic.")
                    .font(GBFont.regular(15)).foregroundColor(GBColor.textPrimary).lineSpacing(4)
                Button(action: onFindMechanic) {
                    Text("Find a mechanic nearby")
                        .font(GBFont.semibold(14)).foregroundColor(GBColor.statusLime)
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(GBColor.lightEmerald.opacity(0.14), in: RoundedRectangle(cornerRadius: GBRadius.small, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: GBRadius.small, style: .continuous)
                            .strokeBorder(GBColor.lightEmerald.opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.top, 12)
            }
            .padding(GBSpace.md)
            .background(GBColor.cream(0.05),
                        in: UnevenRoundedRectangle(topLeadingRadius: 18, bottomLeadingRadius: 5,
                                                   bottomTrailingRadius: 18, topTrailingRadius: 18, style: .continuous))
            .overlay(UnevenRoundedRectangle(topLeadingRadius: 18, bottomLeadingRadius: 5,
                                            bottomTrailingRadius: 18, topTrailingRadius: 18, style: .continuous)
                .strokeBorder(GBColor.cream(0.16), lineWidth: 1))
            Spacer(minLength: 32)
        }
    }
}

/// Animated "thinking" dots for the in-flight assistant bubble.
struct TypingDots: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase = 0
    private let timer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { i in
                Circle().fill(GBColor.statusLime.opacity(phase == i ? 1 : 0.35))
                    .frame(width: 7, height: 7)
            }
        }
        .onReceive(timer) { _ in if !reduceMotion { phase = (phase + 1) % 3 } }
    }
}
