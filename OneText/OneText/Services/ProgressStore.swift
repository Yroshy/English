import Foundation
import Combine

/// Single source of truth for the learner's gamification state (streaks, XP,
/// current/completed weeks) and CEFR level. Persisted locally as JSON in
/// UserDefaults — enough for a single-user, on-device MVP.
@MainActor
final class ProgressStore: ObservableObject {
    @Published private(set) var progress: UserProgress

    private let defaultsKey = "com.vinicius.onetext.userProgress"
    private var calendar: Calendar { Calendar.current }

    init() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode(UserProgress.self, from: data) {
            self.progress = decoded
        } else {
            self.progress = UserProgress()
        }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }

    // MARK: - Onboarding / level

    func completeOnboarding(level: CEFRLevel) {
        progress.level = level
        progress.hasOnboarded = true
        persist()
    }

    func changeLevel(to level: CEFRLevel) {
        progress.level = level
        persist()
    }

    // MARK: - Weeks

    var usedTitles: [String] {
        (progress.completedWeeks.map { $0.weeklyText.title }) + [progress.currentWeek?.weeklyText.title].compactMap { $0 }
    }

    func startNewWeek(with text: WeeklyText) {
        progress.currentWeek = WeekRecord(weeklyText: text, completedDays: [])
        persist()
    }

    func saveWritingSubmission(_ userText: String, feedback: WritingFeedback?) {
        progress.currentWeek?.writingSubmission = userText
        progress.currentWeek?.writingFeedback = feedback
        persist()
    }

    func saveSundayRecall(_ text: String) {
        progress.currentWeek?.sundayRecallText = text
        persist()
    }

    /// Marks a day's mission as complete, awards XP, and updates the streak.
    /// Safe to call multiple times for the same day (idempotent for XP/streak).
    @discardableResult
    func completeDay(_ day: StudyDay) -> Bool {
        guard var week = progress.currentWeek else { return false }
        let alreadyDone = week.completedDays.contains(day)
        week.completedDays.insert(day)
        if week.isComplete && week.completedAt == nil {
            week.completedAt = Date()
        }
        progress.currentWeek = week

        if !alreadyDone {
            progress.xpTotal += day.xpReward
            registerActivityToday()
            if day == .monday {
                enqueueReviewCards(for: week)
            }
        }

        if week.isComplete {
            archiveCurrentWeekIfComplete()
        }

        persist()
        return !alreadyDone
    }

    private func archiveCurrentWeekIfComplete() {
        guard let week = progress.currentWeek, week.isComplete else { return }
        progress.completedWeeks.append(week)
        progress.currentWeek = nil
    }

    // MARK: - Spaced repetition review

    /// Adds one review card per key chunk of a just-completed Monday, so the
    /// learner can start reviewing this week's expressions immediately — and
    /// keeps growing the pool with every past week, regardless of which week
    /// is currently active.
    private func enqueueReviewCards(for week: WeekRecord) {
        let existingKeys = Set(progress.reviewCards.map { "\($0.sourceTitle)|\($0.expression)" })
        let newCards = week.weeklyText.keyChunks
            .map { ReviewCard(chunk: $0, sourceTitle: week.weeklyText.title, sourceLevel: week.weeklyText.level) }
            .filter { !existingKeys.contains("\($0.sourceTitle)|\($0.expression)") }
        progress.reviewCards.append(contentsOf: newCards)
    }

    /// Cards due for review right now, oldest-due first, across ALL studied
    /// weeks (past and current).
    func dueReviewCards(limit: Int = 20) -> [ReviewCard] {
        let now = Date()
        return progress.reviewCards
            .filter { $0.dueDate <= now }
            .sorted { $0.dueDate < $1.dueDate }
            .prefix(limit)
            .map { $0 }
    }

    var totalReviewCardCount: Int { progress.reviewCards.count }
    var dueReviewCardCount: Int { progress.reviewCards.filter { $0.dueDate <= Date() }.count }

    /// Grades a card (Again/Good/Easy), reschedules it with the SM-2-style
    /// algorithm, and rewards a small amount of XP — reviewing counts as
    /// daily activity for the streak too, just like completing a mission.
    @discardableResult
    func gradeReviewCard(_ cardID: UUID, grade: ReviewGrade) -> Bool {
        guard let index = progress.reviewCards.firstIndex(where: { $0.id == cardID }) else { return false }
        SpacedRepetition.schedule(&progress.reviewCards[index], grade: grade)
        progress.xpTotal += 5
        registerActivityToday()
        persist()
        return true
    }

    // MARK: - Streak

    private func registerActivityToday() {
        let today = calendar.startOfDay(for: Date())
        guard let last = progress.lastActiveDate else {
            progress.currentStreak = 1
            progress.lastActiveDate = today
            progress.longestStreak = max(progress.longestStreak, progress.currentStreak)
            return
        }
        let lastDay = calendar.startOfDay(for: last)
        if lastDay == today {
            // Already active today — no change.
        } else if let daysBetween = calendar.dateComponents([.day], from: lastDay, to: today).day, daysBetween == 1 {
            progress.currentStreak += 1
        } else {
            progress.currentStreak = 1
        }
        progress.lastActiveDate = today
        progress.longestStreak = max(progress.longestStreak, progress.currentStreak)
    }

    /// Call on app foreground to reset the streak if a day was missed entirely.
    func evaluateStreakDecay() {
        guard let last = progress.lastActiveDate else { return }
        let today = calendar.startOfDay(for: Date())
        let lastDay = calendar.startOfDay(for: last)
        if let daysBetween = calendar.dateComponents([.day], from: lastDay, to: today).day, daysBetween > 1 {
            progress.currentStreak = 0
            persist()
        }
    }
}
