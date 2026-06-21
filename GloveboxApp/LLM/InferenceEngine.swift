import Foundation

enum InferenceError: Error { case modelMissing, notLoaded }

/// Abstraction so the chat layer doesn't depend on llama directly (and can be
/// swapped/mocked). Main-actor-isolated: the chat layer drives it from the UI.
@MainActor
protocol InferenceEngine: AnyObject {
    var isReady: Bool { get }
    func load() async throws
    /// Streams text deltas as they are generated. Throws on failure; the caller
    /// is responsible for the model-failure fallback.
    func generate(prompt: String, maxTokens: Int) -> AsyncThrowingStream<String, Error>
}

/// llama.cpp-backed engine. Loading and per-token decoding happen on the
/// `LlamaContext` actor's background executor; the main thread only forwards the
/// streamed deltas, so the UI never blocks.
@MainActor
final class LlamaInference: InferenceEngine {
    private var context: LlamaContext?
    private(set) var isReady = false

    func load() async throws {
        #if DEBUG
        // Dev-only: exercise the model-failure fallback deterministically.
        if ProcessInfo.processInfo.environment["GB_FORCE_MODEL_FAIL"] == "1" {
            throw InferenceError.modelMissing
        }
        #endif
        guard context == nil else { return }
        guard let url = ModelLocator.resolve() else { throw InferenceError.modelMissing }
        let path = url.path
        context = try await Task.detached(priority: .userInitiated) {
            try LlamaContext.create(modelPath: path)
        }.value
        isReady = true
    }

    func generate(prompt: String, maxTokens: Int = 256) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let work = Task {
                do {
                    guard let context else { throw InferenceError.notLoaded }
                    try await context.begin(prompt: prompt, maxTokens: maxTokens)
                    while !Task.isCancelled {
                        guard let piece = try await context.next() else { break }
                        if !piece.isEmpty { continuation.yield(piece) }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in work.cancel() }
        }
    }
}
