import Foundation

/// Lightweight on-device retrieval over a vehicle's cached `ManualChunk`s.
/// Keyword-overlap scoring (title weighted higher). This is the grounding step
/// of the RAG pipeline; a vector index can replace the scorer behind this same
/// interface later without touching callers.
struct RetrievedChunk {
    let chunk: ManualChunk
    let score: Double
}

enum Retriever {
    /// Score threshold above which we consider a chunk a genuine grounding match.
    static let strongMatch = 0.18

    static func retrieve(query: String, from chunks: [ManualChunk], topK: Int = 3) -> [RetrievedChunk] {
        let queryTerms = tokenize(query)
        guard !queryTerms.isEmpty, !chunks.isEmpty else { return [] }
        let qSet = Set(queryTerms)

        let scored: [RetrievedChunk] = chunks.compactMap { chunk in
            let titleTerms = Set(tokenize(chunk.title))
            let bodyTerms = Set(tokenize(chunk.text))
            guard !bodyTerms.isEmpty || !titleTerms.isEmpty else { return nil }

            let titleHits = qSet.intersection(titleTerms).count
            let bodyHits = qSet.intersection(bodyTerms).count
            if titleHits == 0 && bodyHits == 0 { return nil }

            // Title matches count triple; normalize by query size.
            let raw = Double(titleHits) * 3.0 + Double(bodyHits)
            let score = raw / Double(qSet.count * 3)
            return RetrievedChunk(chunk: chunk, score: score)
        }

        return Array(scored.sorted { $0.score > $1.score }.prefix(topK))
    }

    private static let stopwords: Set<String> = [
        "the","a","an","is","are","my","i","to","of","and","or","in","on","it","its",
        "do","how","what","why","when","with","for","this","that","im","ive","can","you",
        "me","be","at","as","if","not","no","get","got"
    ]

    static func tokenize(_ text: String) -> [String] {
        text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 2 && !stopwords.contains($0) }
    }
}
