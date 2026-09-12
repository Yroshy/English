import Foundation

/// A comprehension question tied to the weekly text (Monday).
struct ComprehensionQuestion: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    let question: String
    let answerHint: String

    enum CodingKeys: String, CodingKey {
        case question, answerHint
    }
}

/// One of the 5 key expressions/chunks selected on Monday, enriched with
/// collocations on Tuesday. We deliberately model "chunks" (multi-word
/// expressions), never isolated single words, per the methodology.
struct KeyChunk: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    let expression: String
    let meaningPT: String
    let exampleFromText: String
    var collocations: [String]
    /// A NEW sentence (not from the original text) that applies one of the
    /// chunk's collocations to a different everyday situation — the "contexto
    /// de aplicação" that reinforces the expression beyond its single
    /// occurrence in the weekly text.
    let usageExample: String

    enum CodingKeys: String, CodingKey {
        case expression, meaningPT, exampleFromText, collocations, usageExample
    }
}

/// A grammar point found in the text, explained in simple terms (Thursday).
struct GrammarPoint: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    let title: String
    let explanationPT: String
    let exampleFromText: String

    enum CodingKeys: String, CodingKey {
        case title, explanationPT, exampleFromText
    }
}

/// AI (or self) feedback on the learner's Friday writing production.
struct WritingFeedback: Codable, Hashable {
    let correctedText: String
    let notesPT: [String]
}

/// The single weekly text that anchors the whole 7-day cycle.
struct WeeklyText: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    let level: CEFRLevel
    let topic: RoutineTopic
    let title: String
    /// The short routine text itself, in English, with a bit of narrative detail
    /// (not a bare, minimal sentence list).
    let body: String
    let comprehensionQuestions: [ComprehensionQuestion]
    /// Exactly 5 chunks, never isolated words.
    let keyChunks: [KeyChunk]
    let grammarPoints: [GrammarPoint]
    let writingPrompt: String
    let speakingPrompt: String
    var createdAt: Date = Date()

    enum CodingKeys: String, CodingKey {
        case level, topic, title, body, comprehensionQuestions, keyChunks, grammarPoints, writingPrompt, speakingPrompt
    }

    /// Splits the body into sentences for sentence-by-sentence shadowing (Wednesday).
    var sentences: [String] {
        body
            .replacingOccurrences(of: "\n", with: " ")
            .components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
