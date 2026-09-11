import SwiftUI

struct MondayReadingView: View {
    let weeklyText: WeeklyText
    @State private var revealedAnswers: Set<UUID> = []
    @State private var reviewedChunks: Set<UUID> = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DayMissionHeader(day: .monday, level: weeklyText.level)

                VStack(alignment: .leading, spacing: 10) {
                    Text(weeklyText.title)
                        .font(.title2.bold())
                    Text(weeklyText.body)
                        .font(.body)
                        .lineSpacing(4)
                }
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))

                SectionLabel(text: "Perguntas de interpretação")
                VStack(spacing: 10) {
                    ForEach(weeklyText.comprehensionQuestions) { q in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(q.question).font(.subheadline.weight(.medium))
                            if revealedAnswers.contains(q.id) {
                                Text(q.answerHint)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Button("Ver resposta") { revealedAnswers.insert(q.id) }
                                    .font(.caption)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }

                SectionLabel(text: "5 chunks novos e úteis")
                Text("Marque como revisado cada expressão depois de entender o significado no contexto.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                VStack(spacing: 10) {
                    ForEach(weeklyText.keyChunks) { chunk in
                        Button {
                            if reviewedChunks.contains(chunk.id) {
                                reviewedChunks.remove(chunk.id)
                            } else {
                                reviewedChunks.insert(chunk.id)
                            }
                        } label: {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: reviewedChunks.contains(chunk.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(reviewedChunks.contains(chunk.id) ? .green : .secondary)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(chunk.expression).font(.subheadline.weight(.semibold))
                                    Text(chunk.meaningPT).font(.caption).foregroundStyle(.secondary)
                                    Text("\u{201C}\(chunk.exampleFromText)\u{201D}")
                                        .font(.caption.italic())
                                        .foregroundStyle(.tertiary)
                                }
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(12)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Segunda-feira")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            CompleteMissionButton(day: .monday, isEnabled: reviewedChunks.count == weeklyText.keyChunks.count)
        }
    }
}
