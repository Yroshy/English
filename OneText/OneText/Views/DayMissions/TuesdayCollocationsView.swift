import SwiftUI

struct TuesdayCollocationsView: View {
    let weeklyText: WeeklyText
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @State private var reviewedChunks: Set<UUID> = []
    @State private var extraCollocations: [UUID: [String]] = [:]
    @State private var loadingChunkID: UUID?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                DayMissionHeader(day: .tuesday, level: weeklyText.level)

                Text("Para cada chunk, veja com quais outras palavras ele combina naturalmente em inglês (collocations). Marque como revisado quando entender os exemplos.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                VStack(spacing: 14) {
                    ForEach(weeklyText.keyChunks) { chunk in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(chunk.expression).font(.headline)
                                Spacer()
                                Button {
                                    toggleReviewed(chunk.id)
                                } label: {
                                    Image(systemName: reviewedChunks.contains(chunk.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(reviewedChunks.contains(chunk.id) ? .green : .secondary)
                                }
                            }

                            let allCollocations = chunk.collocations + (extraCollocations[chunk.id] ?? [])
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(allCollocations, id: \.self) { collocation in
                                    HStack(alignment: .top, spacing: 6) {
                                        Text("•")
                                        Text(collocation).font(.subheadline)
                                    }
                                }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("CONTEXTO DE APLICAÇÃO")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.tint)
                                Text(chunk.usageExample)
                                    .font(.subheadline.italic())
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))

                            Button {
                                Task { await loadMore(for: chunk) }
                            } label: {
                                if loadingChunkID == chunk.id {
                                    ProgressView().controlSize(.small)
                                } else {
                                    Label("Gerar mais collocations", systemImage: "sparkles")
                                        .font(.caption)
                                }
                            }
                            .disabled(loadingChunkID != nil)
                        }
                        .padding(12)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Terça-feira")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            CompleteMissionButton(day: .tuesday, isEnabled: reviewedChunks.count == weeklyText.keyChunks.count)
        }
    }

    private func toggleReviewed(_ id: UUID) {
        if reviewedChunks.contains(id) { reviewedChunks.remove(id) } else { reviewedChunks.insert(id) }
    }

    private func loadMore(for chunk: KeyChunk) async {
        loadingChunkID = chunk.id
        defer { loadingChunkID = nil }
        if let more = await homeViewModel.refreshCollocations(for: chunk.expression, level: weeklyText.level) {
            let existing = Set(chunk.collocations + (extraCollocations[chunk.id] ?? []))
            let newOnes = more.filter { !existing.contains($0) }
            extraCollocations[chunk.id, default: []].append(contentsOf: newOnes)
        }
    }
}
