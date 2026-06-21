import Foundation
import SwiftData
import Observation

/// Orchestrates a diagnosis turn:
/// input safety → retrieval (RAG) → grounded prompt → on-device generation →
/// output safety → persist. Fails closed (model failure → low-confidence
/// fallback; disallowed topic → safety-block branch).
@MainActor
@Observable
final class DiagnoseViewModel {
    var isGenerating = false
    var streamingText = ""
    var streamingSource: String?

    private let greeting = "I've got your vehicle's owner's manual and common-issue guide saved on this phone. What's the car doing?"

    /// Seed the assistant greeting once per vehicle.
    func ensureGreeting(vehicle: Vehicle, context: ModelContext) {
        if vehicle.messages.isEmpty {
            insert(.init(role: .bot, text: greeting), vehicle: vehicle, context: context)
        }
    }

    /// Clear this vehicle's conversation and start fresh with the greeting.
    func clearConversation(vehicle: Vehicle, context: ModelContext) {
        guard !isGenerating else { return }
        for message in vehicle.messages { context.delete(message) }
        try? context.save()
        ensureGreeting(vehicle: vehicle, context: context)
    }

    func send(_ rawText: String, vehicle: Vehicle, context: ModelContext, engine: InferenceEngine) async {
        let query = rawText.trimmed
        guard !query.isEmpty, !isGenerating else { return }

        // Snapshot history BEFORE adding the new user turn.
        let history = vehicle.messages
            .sorted { $0.createdAt < $1.createdAt }
            .compactMap { m -> PromptBuilder.Turn? in
                switch m.role {
                case .user: return .init(isUser: true, text: m.text)
                case .bot:  return .init(isUser: false, text: m.text)
                default:    return nil
                }
            }

        insert(.init(role: .user, text: query), vehicle: vehicle, context: context)

        // 1) Input safety — short-circuit before any inference.
        if case .block(let topic) = SafetyFilter.classifyInput(query) {
            insert(.init(role: .block, text: "", blockedTopic: topic), vehicle: vehicle, context: context)
            return
        }

        isGenerating = true
        streamingText = ""
        streamingSource = nil
        defer { isGenerating = false; streamingText = ""; streamingSource = nil }

        // 2) Ensure the model is loaded (off the main thread). Failure → fallback.
        do { try await engine.load() }
        catch { insert(.init(role: .fallback, text: ""), vehicle: vehicle, context: context); return }

        // 3) Retrieve grounding from this vehicle's cached manual.
        let hits = Retriever.retrieve(query: query, from: vehicle.manualChunks)
        let grounded = (hits.first?.score ?? 0) >= Retriever.strongMatch
        let topChunk = hits.first?.chunk
        streamingSource = grounded ? sourceLabel(for: topChunk) : "Based on general knowledge"

        // 4) Build the grounded prompt + generate.
        let prompt = PromptBuilder.build(
            vehicleName: vehicle.displayName,
            history: history,
            query: query,
            context: grounded ? hits : [])
        let produced = await generate(engine: engine, prompt: prompt)
        let answer = clean(produced)

        // 5) Output safety — backstop. Disallowed answer → safety block.
        if case .block(let topic) = SafetyFilter.classifyOutput(answer) {
            insert(.init(role: .block, text: "", blockedTopic: topic), vehicle: vehicle, context: context)
            return
        }

        // 6) Model-failure / empty / too-short → low-confidence fallback.
        guard answer.count >= 2 else {
            insert(.init(role: .fallback, text: ""), vehicle: vehicle, context: context)
            return
        }

        let safeToDIY = grounded && (topChunk?.safeForDIY ?? false)
        insert(.init(role: .bot, text: answer,
                     source: grounded ? sourceLabel(for: topChunk) : "Based on general knowledge",
                     safeForDIY: safeToDIY),
               vehicle: vehicle, context: context)
    }

    // MARK: - Generation with watchdog timeout
    private func generate(engine: InferenceEngine, prompt: String) async -> String {
        let gen = Task { @MainActor () -> String in
            var produced = ""
            do {
                for try await piece in engine.generate(prompt: prompt, maxTokens: 220) {
                    produced += piece
                    self.streamingText = self.clean(produced)
                }
            } catch { /* return whatever we have; caller decides fallback */ }
            return produced
        }
        // Watchdog: on-device this finishes fast; the simulator runs CPU-only and is slow.
        let watchdog = Task { try? await Task.sleep(for: .seconds(120)); gen.cancel() }
        let result = await gen.value
        watchdog.cancel()
        return result
    }

    // MARK: - Helpers
    private func insert(_ message: ChatMessage, vehicle: Vehicle, context: ModelContext) {
        message.vehicle = vehicle
        context.insert(message)
        try? context.save()
    }

    private func sourceLabel(for chunk: ManualChunk?) -> String {
        switch chunk?.section {
        case "Owner's manual":        return "From your cached owner's manual"
        case "Common issues & fixes": return "From your cached common-issue guide"
        case "Warning-light meanings":return "From your cached warning-light guide"
        case "Fluids & capacities":   return "From your cached fluids & capacities"
        case "Torque specs":          return "From your cached torque specs"
        default:                      return "From your cached manual"
        }
    }

    /// Strip any stray chat-template special tokens and tidy whitespace.
    private func clean(_ text: String) -> String {
        var t = text
        for marker in ["<|eot_id|>", "<|start_header_id|>", "<|end_header_id|>",
                       "<|begin_of_text|>", "assistant", "<|python_tag|>"] {
            if marker == "assistant" {
                // only strip a leading stray "assistant" label
                if t.hasPrefix("assistant") { t.removeFirst("assistant".count) }
            } else {
                t = t.replacingOccurrences(of: marker, with: "")
            }
        }
        return t.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
