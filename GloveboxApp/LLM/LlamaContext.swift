import Foundation
import llama

/// Thin Swift actor over the llama.cpp C API (xcframework b9748). Being an actor,
/// all inference runs on a background executor — never the main thread. Mirrors
/// the canonical `simple.cpp` generation loop.
actor LlamaContext {
    enum GenError: Error { case modelLoad, contextInit, tokenize, decode }

    private let model: OpaquePointer
    private let context: OpaquePointer
    private let vocab: OpaquePointer
    private var sampler: UnsafeMutablePointer<llama_sampler>?

    private var pendingBytes: [UInt8] = []
    private var generated = 0
    private var maxTokens = 256

    private init(model: OpaquePointer, context: OpaquePointer) {
        self.model = model
        self.context = context
        self.vocab = llama_model_get_vocab(model)
    }

    deinit {
        if let sampler { llama_sampler_free(sampler) }
        llama_free(context)
        llama_model_free(model)
        llama_backend_free()
    }

    /// Load the model + create a context. Heavy — call from a background task.
    static func create(modelPath: String, nCtx: UInt32 = 2048) throws -> LlamaContext {
        llama_backend_init()

        var modelParams = llama_model_default_params()
        #if targetEnvironment(simulator)
        modelParams.n_gpu_layers = 0          // Metal isn't reliable on the simulator
        #else
        modelParams.n_gpu_layers = 99         // offload everything to Metal on device
        #endif

        guard let model = llama_model_load_from_file(modelPath, modelParams) else {
            llama_backend_free()
            throw GenError.modelLoad
        }

        var ctxParams = llama_context_default_params()
        ctxParams.n_ctx = nCtx
        let threads = Int32(max(1, ProcessInfo.processInfo.activeProcessorCount - 1))
        ctxParams.n_threads = threads
        ctxParams.n_threads_batch = threads

        guard let context = llama_init_from_model(model, ctxParams) else {
            llama_model_free(model)
            llama_backend_free()
            throw GenError.contextInit
        }
        return LlamaContext(model: model, context: context)
    }

    /// Begin a fresh generation: clears KV memory, tokenizes the full prompt,
    /// decodes it, and resets the sampler.
    func begin(prompt: String, maxTokens: Int) throws {
        llama_memory_clear(llama_get_memory(context), true)
        pendingBytes.removeAll(keepingCapacity: true)
        generated = 0
        self.maxTokens = maxTokens

        if let sampler { llama_sampler_free(sampler) }
        let chain = llama_sampler_chain_init(llama_sampler_chain_default_params())
        llama_sampler_chain_add(chain, llama_sampler_init_top_k(40))
        llama_sampler_chain_add(chain, llama_sampler_init_top_p(0.9, 1))
        llama_sampler_chain_add(chain, llama_sampler_init_temp(0.3))
        llama_sampler_chain_add(chain, llama_sampler_init_dist(UInt32.max)) // LLAMA_DEFAULT_SEED
        sampler = chain

        var tokens = tokenize(prompt, addSpecial: false, parseSpecial: true)
        guard !tokens.isEmpty else { throw GenError.tokenize }

        // Keep prompt + generation within the context window (drop oldest if needed).
        let limit = Int(llama_n_ctx(context)) - maxTokens - 4
        if limit > 0, tokens.count > limit { tokens = Array(tokens.suffix(limit)) }

        let batch = llama_batch_get_one(&tokens, Int32(tokens.count))
        guard llama_decode(context, batch) == 0 else { throw GenError.decode }
    }

    /// Produce the next decodable text delta, or nil when generation is finished
    /// (end-of-generation token or token budget reached). May return "" while it
    /// waits for the rest of a multi-byte UTF-8 sequence.
    func next() throws -> String? {
        guard let sampler else { return nil }

        var token = llama_sampler_sample(sampler, context, -1)
        generated += 1
        if llama_vocab_is_eog(vocab, token) || generated > maxTokens { return nil }

        pendingBytes.append(contentsOf: pieceBytes(token))

        let batch = llama_batch_get_one(&token, 1)
        guard llama_decode(context, batch) == 0 else { return nil }

        if let text = String(bytes: pendingBytes, encoding: .utf8) {
            pendingBytes.removeAll(keepingCapacity: true)
            return text
        }
        return "" // incomplete UTF-8 — keep accumulating
    }

    // MARK: - Helpers

    private func tokenize(_ text: String, addSpecial: Bool, parseSpecial: Bool) -> [llama_token] {
        let byteLen = Int32(text.utf8.count)
        let capacity = Int(byteLen) + 16
        var out = [llama_token](repeating: 0, count: capacity)
        let n = text.withCString {
            llama_tokenize(vocab, $0, byteLen, &out, Int32(capacity), addSpecial, parseSpecial)
        }
        if n < 0 {
            let needed = Int(-n)
            out = [llama_token](repeating: 0, count: needed)
            let n2 = text.withCString {
                llama_tokenize(vocab, $0, byteLen, &out, Int32(needed), addSpecial, parseSpecial)
            }
            return Array(out.prefix(max(0, Int(n2))))
        }
        return Array(out.prefix(Int(n)))
    }

    private func pieceBytes(_ token: llama_token) -> [UInt8] {
        var buf = [CChar](repeating: 0, count: 64)
        var n = llama_token_to_piece(vocab, token, &buf, Int32(buf.count), 0, false)
        if n < 0 {
            buf = [CChar](repeating: 0, count: Int(-n))
            n = llama_token_to_piece(vocab, token, &buf, Int32(buf.count), 0, false)
        }
        guard n > 0 else { return [] }
        return buf.prefix(Int(n)).map { UInt8(bitPattern: $0) }
    }
}
