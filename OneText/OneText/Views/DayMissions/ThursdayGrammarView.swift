import SwiftUI

struct ThursdayGrammarView: View {
    let weeklyText: WeeklyText
    @State private var reviewedPoints: Set<UUID> = []
    @State private var showingText = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                DayMissionHeader(day: .thursday, level: weeklyText.level)

                Text("Veja os pontos gramaticais escondidos no texto da semana, com explicação simples e exemplo real.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                DisclosureGroup("Reler o texto", isExpanded: $showingText) {
                    Text(weeklyText.body)
                        .font(.subheadline)
                        .lineSpacing(3)
                        .padding(.top, 6)
                }
                .padding(12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

                VStack(spacing: 12) {
                    ForEach(weeklyText.grammarPoints) { point in
                        Button {
                            if reviewedPoints.contains(point.id) {
                                reviewedPoints.remove(point.id)
                            } else {
                                reviewedPoints.insert(point.id)
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(point.title).font(.headline)
                                    Spacer()
                                    Image(systemName: reviewedPoints.contains(point.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(reviewedPoints.contains(point.id) ? .green : .secondary)
                                }
                                Text(point.explanationPT)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("\u{201C}\(point.exampleFromText)\u{201D}")
                                    .font(.caption.italic())
                                    .foregroundStyle(.tertiary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                        .padding(12)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Quinta-feira")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            CompleteMissionButton(day: .thursday, isEnabled: reviewedPoints.count == weeklyText.grammarPoints.count)
        }
    }
}
