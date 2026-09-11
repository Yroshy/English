import SwiftUI
import AVFoundation

struct WednesdayListeningView: View {
    let weeklyText: WeeklyText
    @StateObject private var speechService = SpeechService()
    @State private var practicedSentences: Set<Int> = []
    @State private var slowMode = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                DayMissionHeader(day: .wednesday, level: weeklyText.level)

                Text("Ouça frase por frase, sem olhar o texto se conseguir. Pause, repita em voz alta imitando o ritmo e a entonação (Shadowing).")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Toggle(isOn: $slowMode) {
                    Label("Velocidade reduzida", systemImage: "tortoise.fill")
                }
                .padding(12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

                VStack(spacing: 10) {
                    ForEach(Array(weeklyText.sentences.enumerated()), id: \.offset) { index, sentence in
                        HStack(spacing: 12) {
                            Button {
                                let rate = slowMode ? AVSpeechUtteranceDefaultSpeechRate * 0.7 : AVSpeechUtteranceDefaultSpeechRate * 0.95
                                speechService.speak(sentence: sentence, at: index, rate: rate)
                                practicedSentences.insert(index)
                            } label: {
                                Image(systemName: speechService.isSpeaking && speechService.currentSentenceIndex == index ? "speaker.wave.2.fill" : "play.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.tint)
                            }

                            Text(sentence + ".")
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if practicedSentences.contains(index) {
                                Image(systemName: "checkmark").font(.caption).foregroundStyle(.green)
                            }
                        }
                        .padding(10)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    }
                }

                Button(role: .destructive) {
                    speechService.stop()
                } label: {
                    Label("Parar áudio", systemImage: "stop.fill")
                }
                .font(.caption)
            }
            .padding()
        }
        .navigationTitle("Quarta-feira")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { speechService.stop() }
        .safeAreaInset(edge: .bottom) {
            CompleteMissionButton(day: .wednesday, isEnabled: practicedSentences.count == weeklyText.sentences.count)
        }
    }
}
