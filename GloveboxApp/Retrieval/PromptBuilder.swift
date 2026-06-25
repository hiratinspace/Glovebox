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
        You are Glovebox, an on-device diagnosis assistant for a \(vehicleName), helping a \
        possibly-stranded driver.

        HOW TO ANSWER:
        - Answer the question DIRECTLY and concretely. Lead with the answer — never open \
        with a disclaimer or "I'm not a mechanic."
        - Give specific, actionable steps in plain imperative language ("Check…", "Turn off…", \
        "Re-seat…"). Include concrete details (what to look for, typical values) from the \
        cached manual when available.
        - Do NOT ask the driver questions back. Do NOT tell them to visit a shop, dealer, or \
        service center UNLESS the issue is safety-critical (see SAFETY).
        - Be calm and brief: 2–5 short sentences.

        SAFETY: The driver may be stranded with no mechanic and no signal, so never refuse to \
        help. You MAY explain how to address any problem, including safety-critical systems \
        (brakes, airbags/SRS, high-voltage EV/hybrid battery, fuel system, structural/frame). \
        For those safety-critical systems you MUST give the practical steps AND clearly warn \
        that the system is dangerous, that they proceed at their own risk, and that they should \
        get it professionally inspected as soon as they can.
        """

        if context.isEmpty {
            system += "\n\nThere is no matching cached manual entry for this question. Answer " +
                      "directly from general automotive knowledge with concrete steps; keep it brief."
        } else {
            let grounding = context.enumerated().map { i, rc in
                "[\(i + 1)] \(rc.chunk.title): \(rc.chunk.text)"
            }.joined(separator: "\n\n")
            system += "\n\nBase your answer on these cached manual excerpts for this exact vehicle. " +
                      "Use their specifics; paraphrase, don't quote tags.\n\n" +
                      "CACHED MANUAL:\n\(grounding)"
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
