import Foundation

enum ContentError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Configure sua chave de API da Anthropic em Ajustes para gerar novos textos com IA."
        case .invalidResponse:
            return "Não foi possível entender a resposta da IA. Tente novamente."
        case .network(let error):
            return "Erro de rede: \(error.localizedDescription)"
        }
    }
}

/// Anything that can produce weekly texts and the day-by-day study material for
/// the 7-day methodology. Two implementations exist:
///  - `LocalContentBank`: static, hand-curated, works fully offline.
///  - `ClaudeContentGenerator`: calls the Anthropic API to generate fresh,
///    real-world routine texts on demand, calibrated to the chosen CEFR level.
protocol ContentGenerating {
    /// Produces a brand new weekly text (with questions, chunks, grammar points,
    /// writing/speaking prompts already filled in) for the given level.
    func generateWeeklyText(level: CEFRLevel, topic: RoutineTopic, avoiding usedTitles: [String]) async throws -> WeeklyText

    /// Regenerates/expands collocations for a single chunk (used on Tuesday for
    /// a "gerar mais" refresh button).
    func generateCollocations(for expression: String, level: CEFRLevel) async throws -> [String]

    /// Produces corrections + short PT explanations for the learner's Friday writing.
    func generateWritingFeedback(userText: String, originalText: String, level: CEFRLevel) async throws -> WritingFeedback
}
