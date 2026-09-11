import SwiftUI

struct StreakXPBar: View {
    let streak: Int
    let xp: Int

    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(streak > 0 ? .orange : .gray)
                Text("\(streak)")
                    .font(.headline)
                Text("dias")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider().frame(height: 20)

            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                Text("\(xp)")
                    .font(.headline)
                Text("XP")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.thinMaterial, in: Capsule())
    }
}
