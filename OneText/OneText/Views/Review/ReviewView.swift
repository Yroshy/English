import SwiftUI

/// Entry point for spaced-repetition practice — reviewing expressions from
/// EVERY week studied so far (not just the current one), the way Anki or
/// Duolingo's review sessions work.
struct ReviewView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @State private var showingSession = false

    private var dueCards: [ReviewCard] { progressStore.dueReviewCards(limit: 20) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if progressStore.totalReviewCardCount == 0 {
                        emptyState
                    } else {
                        summaryCard
                        if !sourceBreakdown.isEmpty {
                            sourceBreakdownList
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Revisão")
            .fullScreenCover(isPresented: $showingSession) {
                ReviewSessionView(cards: dueCards)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 40))
                .foregroundStyle(.tint)
            Text("Ainda não há cartões de revisão")
                .font(.headline)
            Text("Assim que você concluir a missão de Segunda-feira de uma semana, os 5 chunks dela viram cartões aqui — e ficam disponíveis para revisão mesmo depois que você já estiver em outra semana.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }

    private var summaryCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack.fill")
                .font(.system(size: 36))
                .foregroundStyle(.tint)

            Text("\(progressStore.dueReviewCardCount)")
                .font(.system(size: 48, weight: .bold))
            Text(progressStore.dueReviewCardCount == 1 ? "cartão para revisar agora" : "cartões para revisar agora")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("\(progressStore.totalReviewCardCount) no total, de todas as semanas já estudadas")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Button {
                showingSession = true
            } label: {
                Label("Iniciar revisão (+5 XP por cartão)", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(progressStore.dueReviewCardCount == 0)

            if progressStore.dueReviewCardCount == 0 {
                Text("Tudo revisado por agora. Volte mais tarde — os cartões reaparecem conforme o intervalo de repetição espaçada.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private struct SourceGroup: Identifiable {
        var id: String { title }
        let title: String
        let level: CEFRLevel
        let count: Int
    }

    private var sourceBreakdown: [SourceGroup] {
        let grouped = Dictionary(grouping: progressStore.progress.reviewCards, by: { $0.sourceTitle })
        return grouped.map { title, cards in
            SourceGroup(title: title, level: cards.first!.sourceLevel, count: cards.count)
        }
        .sorted { $0.title < $1.title }
    }

    private var sourceBreakdownList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Textos no seu banco de revisão")
                .font(.headline)
            ForEach(sourceBreakdown) { group in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(group.title).font(.subheadline)
                        Text(group.level.displayName).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(group.count) chunks")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(10)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
