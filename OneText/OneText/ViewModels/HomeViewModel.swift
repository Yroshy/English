import Foundation

/// Orchestrates weekly text loading (AI-generated when an API key is present,
/// falling back to the offline seed bank otherwise) and exposes helpers the
/// day-mission views use (collocations refresh, writing feedback).
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var isGenerating = false
    @Published var errorMessage: String?

    private let localBank = LocalContentBank()
    private var aiGenerator: ClaudeContentGenerator { ClaudeContentGenerator() }

    private var activeGenerator: ContentGenerating {
        APIKeyStore.hasKey ? aiGenerator : localBank
    }

    /// Ensures there is a current week in progress; generates one if needed.
    func ensureCurrentWeek(store progressStore: ProgressStore) async {
        guard progressStore.progress.currentWeek == nil, let level = progressStore.progress.level else { return }
        await generateNewWeek(level: level, store: progressStore)
    }

    func startNextWeek(store progressStore: ProgressStore) async {
        guard let level = progressStore.progress.level else { return }
        await generateNewWeek(level: level, store: progressStore)
    }

    private func generateNewWeek(level: CEFRLevel, store progressStore: ProgressStore) async {
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }

        let topic = RoutineTopic.allCases.randomElement() ?? .morningRoutine
        do {
            let text = try await activeGenerator.generateWeeklyText(level: level, topic: topic, avoiding: progressStore.usedTitles)
            progressStore.startNewWeek(with: text)
        } catch {
            // Fall back to the offline bank so the learner is never blocked.
            if let text = try? await localBank.generateWeeklyText(level: level, topic: topic, avoiding: progressStore.usedTitles) {
                progressStore.startNewWeek(with: text)
                if APIKeyStore.hasKey {
                    errorMessage = "Não foi possível gerar um novo texto com IA agora. Usando um texto offline."
                }
            } else {
                errorMessage = "Não foi possível carregar um texto. Tente novamente."
            }
        }
    }

    func refreshCollocations(for expression: String, level: CEFRLevel) async -> [String]? {
        try? await activeGenerator.generateCollocations(for: expression, level: level)
    }

    func requestWritingFeedback(userText: String, originalText: String, level: CEFRLevel) async -> Result<WritingFeedback, Error> {
        do {
            let feedback = try await activeGenerator.generateWritingFeedback(userText: userText, originalText: originalText, level: level)
            return .success(feedback)
        } catch {
            return .failure(error)
        }
    }
}
