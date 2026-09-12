import SwiftUI

struct SundayReviewView: View {
    let weeklyText: WeeklyText
    @EnvironmentObject private var progressStore: ProgressStore
    @State private var recallText: String = ""
    @State private var showingOriginal = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DayMissionHeader(day: .sunday, level: weeklyText.level)

                Text("Feche o material e tente se lembrar das estruturas, verbos e expressões que você estudou esta semana. Se quiser, reescreva o texto de memória.")
                    .font(.subheadline)
                    .padding(12)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

                Text("Reescreva o texto de memória (opcional, mas recomendado):")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextEditor(text: $recallText)
                    .frame(minHeight: 140)
                    .padding(8)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .onChange(of: recallText) { newValue in
                        progressStore.saveSundayRecall(newValue)
                    }

                DisclosureGroup("Comparar com o texto original", isExpanded: $showingOriginal) {
                    Text(weeklyText.body)
                        .font(.subheadline)
                        .lineSpacing(3)
                        .padding(.top, 6)
                }
                .padding(12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 6) {
                    Text("Antes de concluir, tente lembrar:").font(.subheadline.weight(.semibold))
                    ForEach(weeklyText.keyChunks) { chunk in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                            Text(chunk.expression).font(.caption)
                        }
                    }
                }
                .padding(12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .navigationTitle("Domingo")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { recallText = progressStore.progress.currentWeek?.sundayRecallText ?? "" }
        .safeAreaInset(edge: .bottom) {
            CompleteMissionButton(day: .sunday)
        }
    }
}
