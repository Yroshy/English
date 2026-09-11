import SwiftUI

struct FridayWritingView: View {
    let weeklyText: WeeklyText
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var progressStore: ProgressStore

    @State private var userText: String = ""
    @State private var feedback: WritingFeedback?
    @State private var isLoadingFeedback = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DayMissionHeader(day: .friday, level: weeklyText.level)

                Text(weeklyText.writingPrompt)
                    .font(.subheadline)
                    .padding(12)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

                TextEditor(text: $userText)
                    .frame(minHeight: 160)
                    .padding(8)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .onChange(of: userText) { newValue in
                        progressStore.saveWritingSubmission(newValue, feedback: feedback)
                    }

                Button {
                    Task { await requestFeedback() }
                } label: {
                    if isLoadingFeedback {
                        ProgressView()
                    } else {
                        Label("Corrigir com IA", systemImage: "wand.and.stars")
                    }
                }
                .buttonStyle(.bordered)
                .disabled(userText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoadingFeedback)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.orange)
                }

                if let feedback {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Texto corrigido").font(.headline)
                        Text(feedback.correctedText).font(.subheadline)
                        if !feedback.notesPT.isEmpty {
                            Divider()
                            Text("Por que corrigi:").font(.subheadline.weight(.semibold))
                            ForEach(feedback.notesPT, id: \.self) { note in
                                HStack(alignment: .top, spacing: 6) {
                                    Text("•")
                                    Text(note).font(.caption)
                                }
                            }
                        }
                    }
                    .padding(12)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("Sexta-feira")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { userText = progressStore.progress.currentWeek?.writingSubmission ?? "" }
        .safeAreaInset(edge: .bottom) {
            CompleteMissionButton(day: .friday, isEnabled: !userText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private func requestFeedback() async {
        isLoadingFeedback = true
        errorMessage = nil
        defer { isLoadingFeedback = false }

        let result = await homeViewModel.requestWritingFeedback(userText: userText, originalText: weeklyText.body, level: weeklyText.level)
        switch result {
        case .success(let fb):
            feedback = fb
            progressStore.saveWritingSubmission(userText, feedback: fb)
        case .failure(let error):
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Não foi possível corrigir agora. Releia seu texto comparando com o texto original."
        }
    }
}
