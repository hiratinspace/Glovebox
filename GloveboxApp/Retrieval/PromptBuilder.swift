import Foundation

/// Builds the grounded prompt in Llama 3.x Instruct chat format. The retrieved
/// manual context is injected as system grounding; the safety rules are stated as
/// defense-in-depth (the real enforcement is `SafetyFilter` in code).
enum PromptBuilder {

    struct Turn { let isUser: Bool; let text: String }

    static func build(vehicleName: String,
                      history: [Turn],
                      query: String,
                      context: [RetrievedChunk]) -> String {

        var system = """
        You are Glovebox, an on-device car-diagnosis assistant for a \(vehicleName). \
        Help a possibly-stranded, stressed driver. Be calm, concise, and practical. \
        Prefer 2–5 short sentences. If you are not confident, say so plainly and \
        recommend a certified mechanic — never guess.

        SAFETY: Never give step-by-step DIY repair instructions for brakes (beyond \
        checking fluid level), airbags/SRS, high-voltage EV/hybrid battery systems, \
        fuel-system repairs (beyond inspecting the cap/lines), or structural/frame \
        work. For those, tell the user to stop and call a professional.
        """

        if context.isEmpty {
            system += "\n\nYou have no matching cached manual content for this question. " +
                      "Answer only from general automotive knowledge, and make clear it is general guidance."
        } else {
            let grounding = context.enumerated().map { i, rc in
                "[\(i + 1)] (\(rc.chunk.section) — \(rc.chunk.title))\n\(rc.chunk.text)"
            }.joined(separator: "\n\n")
            system += "\n\nUse the following cached manual excerpts as your primary source. " +
                      "If they don't cover the question, say what you do and don't know.\n\n" +
                      "CACHED MANUAL CONTEXT:\n\(grounding)"
        }

        var prompt = "<|begin_of_text|><|start_header_id|>system<|end_header_id|>\n\n\(system)<|eot_id|>"

        // Include a short window of prior turns for continuity.
        for turn in history.suffix(4) {
            let role = turn.isUser ? "user" : "assistant"
            prompt += "<|start_header_id|>\(role)<|end_header_id|>\n\n\(turn.text)<|eot_id|>"
        }

        prompt += "<|start_header_id|>user<|end_header_id|>\n\n\(query)<|eot_id|>"
        prompt += "<|start_header_id|>assistant<|end_header_id|>\n\n"
        return prompt
    }
}
