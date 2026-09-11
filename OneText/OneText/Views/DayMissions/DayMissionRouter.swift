import SwiftUI

/// Routes a `StudyDay` to its dedicated mission screen, all sharing the same
/// weekly text as their anchor — the core of the "one text, seven days" idea.
struct DayMissionRouter: View {
    let day: StudyDay
    let weeklyText: WeeklyText

    var body: some View {
        switch day {
        case .monday:
            MondayReadingView(weeklyText: weeklyText)
        case .tuesday:
            TuesdayCollocationsView(weeklyText: weeklyText)
        case .wednesday:
            WednesdayListeningView(weeklyText: weeklyText)
        case .thursday:
            ThursdayGrammarView(weeklyText: weeklyText)
        case .friday:
            FridayWritingView(weeklyText: weeklyText)
        case .saturday:
            SaturdaySpeakingView(weeklyText: weeklyText)
        case .sunday:
            SundayReviewView(weeklyText: weeklyText)
        }
    }
}

/// Shared footer button every day-mission screen uses to mark the mission done
/// and award XP, mirroring Duolingo's "complete daily lesson" moment.
struct CompleteMissionButton: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @Environment(\.dismiss) private var dismiss
    let day: StudyDay
    var isEnabled: Bool = true

    @State private var justCompleted = false

    var body: some View {
        let alreadyDone = progressStore.progress.currentWeek?.completedDays.contains(day) ?? false

        Button {
            progressStore.completeDay(day)
            justCompleted = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { dismiss() }
        } label: {
            Label(
                alreadyDone ? "Concluído ✓" : "Concluir dia (+\(day.xpReward) XP)",
                systemImage: alreadyDone ? "checkmark.circle.fill" : "checkmark.circle"
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(alreadyDone ? .green : .accentColor)
        .disabled(!isEnabled || alreadyDone)
        .padding(.horizontal)
        .padding(.bottom)
    }
}
