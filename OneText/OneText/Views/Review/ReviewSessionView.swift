import SwiftUI

/// The flashcard "game": one cloze sentence at a time, self-graded with
/// Again / Good / Easy, which reschedules the card via spaced repetition.
struct ReviewSessionView: View {
    let cards: [ReviewCard]

    @EnvironmentObject private var progressStore: ProgressStore
    @Environment(\.dismiss) private var dismiss

    @State private var index = 0
    @State private var revealed = false
    @State private var isFinished = false

    var body: some View {
        NavigationStack {
            Group {
                if cards.isEmpty {
                    emptyState
                } else if isFinished {
                    completionState
                } else {
                    sessionContent
                }
            }
            .navigationTitle("Revisão")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
    }

    private var currentCard: ReviewCard? {
        cards.indices.contains(index) ? cards[index] : nil
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.green)
            Text("Nada para revisar agora")
                .font(.headline)
        }
    }

    private var completionState: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.yellow)
            Text("Revisão concluída!")
                .font(.title2.bold())
            Text("Você revisou \(cards.count) cartão\(cards.count == 1 ? "" : "es") e ganhou +\(cards.count * 5) XP.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                dismiss()
            } label: {
                Text("Concluir").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 40)
        }
        .padding()
    }

    @ViewBuilder
    private var sessionContent: some View {
        if let card = currentCard {
            VStack(spacing: 20) {
                ProgressView(value: Double(index), total: Double(cards.count))
                    .padding(.horizontal)
                Text("\(index + 1) de \(cards.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(card.sourceTitle)
                            Spacer()
                            Text(card.sourceLevel.displayName)
                        }
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.tint)

                        Text(card.clozeSentence + ".")
                            .font(.title3.weight(.medium))
                            .lineSpacing(4)

                        if revealed {
                            VStack(alignment: .leading, spacing: 12) {
                                Divider()
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(card.expression).font(.headline)
                                    Text(card.meaningPT).font(.subheadline).foregroundStyle(.secondary)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("COLLOCATIONS").font(.caption2.weight(.bold)).foregroundStyle(.tertiary)
                                    ForEach(card.collocations, id: \.self) { c in
                                        Text("• \(c)").font(.caption)
                                    }
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("CONTEXTO DE APLICAÇÃO").font(.caption2.weight(.bold)).foregroundStyle(.tertiary)
                                    Text(card.usageExample).font(.caption.italic())
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }

                if revealed {
                    HStack(spacing: 10) {
                        gradeButton("Não lembrei", color: .red) { grade(.again) }
                        gradeButton("Bom", color: .blue) { grade(.good) }
                        gradeButton("Fácil", color: .green) { grade(.easy) }
                    }
                    .padding(.horizontal)
                } else {
                    Button {
                        revealed = true
                    } label: {
                        Text("Mostrar resposta").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }

    private func gradeButton(_ title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.borderedProminent)
        .tint(color)
    }

    private func grade(_ grade: ReviewGrade) {
        guard let card = currentCard else { return }
        progressStore.gradeReviewCard(card.id, grade: grade)
        revealed = false
        if index + 1 < cards.count {
            index += 1
        } else {
            isFinished = true
        }
    }
}
