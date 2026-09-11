import Foundation

/// A flashcard for spaced-repetition review, generated from a `KeyChunk`
/// once its week's Monday mission is completed. Presented as a cloze
/// ("fill in the blank") game so the learner recalls the expression inside
/// a real sentence, not in isolation — reviewing texts from PAST weeks even
/// while a new week's text is in progress.
struct ReviewCard: Codable, Identifiable, Hashable {
    var id: UUID = UUID()

    let expression: String
    let meaningPT: String
    /// The original sentence from the text, with the expression blanked out.
    let clozeSentence: String
    let collocations: [String]
    let usageExample: String
    let sourceTitle: String
    let sourceLevel: CEFRLevel

    // Spaced-repetition (simplified SM-2) state.
    var dueDate: Date = Date()
    var intervalDays: Int = 0
    var easeFactor: Double = 2.5
    var repetitions: Int = 0
    var lapses: Int = 0

    enum CodingKeys: String, CodingKey {
        case id, expression, meaningPT, clozeSentence, collocations, usageExample, sourceTitle, sourceLevel, dueDate, intervalDays, easeFactor, repetitions, lapses
    }

    init(chunk: KeyChunk, sourceTitle: String, sourceLevel: CEFRLevel) {
        self.expression = chunk.expression
        self.meaningPT = chunk.meaningPT
        self.clozeSentence = Self.makeCloze(from: chunk.exampleFromText, expression: chunk.expression)
        self.collocations = chunk.collocations
        self.usageExample = chunk.usageExample
        self.sourceTitle = sourceTitle
        self.sourceLevel = sourceLevel
    }

    private static func makeCloze(from sentence: String, expression: String) -> String {
        guard let range = sentence.range(of: expression, options: [.caseInsensitive]) else {
            return sentence
        }
        return sentence.replacingCharacters(in: range, with: "▁▁▁▁▁")
    }
}

/// The three self-graded outcomes offered during a review session, mirroring
/// Anki's "Again / Good / Easy" (a simplified, 3-button take on SM-2).
enum ReviewGrade {
    case again
    case good
    case easy
}

/// A minimal SM-2-style scheduler: grows the interval between reviews as the
/// learner keeps remembering a card, and resets it when they forget.
enum SpacedRepetition {
    static func schedule(_ card: inout ReviewCard, grade: ReviewGrade) {
        switch grade {
        case .again:
            card.lapses += 1
            card.repetitions = 0
            card.intervalDays = 1
            card.easeFactor = max(1.3, card.easeFactor - 0.2)

        case .good:
            card.repetitions += 1
            switch card.repetitions {
            case 1: card.intervalDays = 1
            case 2: card.intervalDays = 6
            default: card.intervalDays = max(1, Int((Double(card.intervalDays) * card.easeFactor).rounded()))
            }

        case .easy:
            card.repetitions += 1
            card.easeFactor += 0.15
            switch card.repetitions {
            case 1, 2: card.intervalDays = 4
            default: card.intervalDays = max(1, Int((Double(card.intervalDays) * card.easeFactor * 1.3).rounded()))
            }
        }

        card.dueDate = Calendar.current.date(byAdding: .day, value: card.intervalDays, to: Date()) ?? Date()
    }
}
