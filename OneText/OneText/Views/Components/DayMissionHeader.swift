import SwiftUI

struct DayMissionHeader: View {
    let day: StudyDay
    let level: CEFRLevel

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: day.symbolName)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color.accentColor, in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(day.title).font(.headline)
                Text(day.subtitle).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            Text(level.displayName)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.accentColor.opacity(0.15), in: Capsule())
        }
    }
}

struct SectionLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.headline)
            .padding(.top, 4)
    }
}
