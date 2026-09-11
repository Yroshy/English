import SwiftUI

struct DayCardView: View {
    let day: StudyDay
    let isCompleted: Bool
    let isNext: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconBackground)
                    .frame(width: 44, height: 44)
                Image(systemName: isCompleted ? "checkmark" : day.symbolName)
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .bold))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(day.shortName) · \(day.title)")
                    .font(.subheadline.weight(.semibold))
                Text(day.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            if isCompleted {
                Text("+\(day.xpReward) XP")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.green)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isNext ? Color.accentColor : .clear, lineWidth: 2)
        )
        .opacity(isCompleted ? 0.75 : 1)
    }

    private var iconBackground: Color {
        isCompleted ? .green : .accentColor
    }
}
