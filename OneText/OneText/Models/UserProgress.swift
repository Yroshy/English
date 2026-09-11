import Foundation

/// A snapshot of a completed (or in-progress) study week, kept for history/review.
struct WeekRecord: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    let weeklyText: WeeklyText
    var completedDays: Set<StudyDay>
    var writingSubmission: String?
    var writingFeedback: WritingFeedback?
    var sundayRecallText: String?
    var startedAt: Date = Date()
    var completedAt: Date?

    var isComplete: Bool { completedDays.count == StudyDay.allCases.count }
    var progress: Double { Double(completedDays.count) / Double(StudyDay.allCases.count) }
}

/// Persisted gamification + level state for the learner. Mirrors the Duolingo-style
/// mechanics requested: daily missions, streaks and XP, layered on top of the
/// weekly single-text methodology.
struct UserProgress: Codable {
    var level: CEFRLevel?
    var xpTotal: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastActiveDate: Date?
    var currentWeek: WeekRecord?
    var completedWeeks: [WeekRecord] = []
    var hasOnboarded: Bool = false
    /// Spaced-repetition pool built from every week's chunks (once Monday is
    /// done), independent of which week is currently in progress — this is
    /// what lets the learner review past texts during the current week.
    var reviewCards: [ReviewCard] = []

    var weeksCompletedCount: Int { completedWeeks.count }
}
