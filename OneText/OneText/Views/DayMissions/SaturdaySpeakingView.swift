import SwiftUI

struct SaturdaySpeakingView: View {
    let weeklyText: WeeklyText
    @StateObject private var recorder = AudioRecorderService()
    @State private var practicedWithoutRecording = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                DayMissionHeader(day: .saturday, level: weeklyText.level)

                Text(weeklyText.speakingPrompt)
                    .font(.subheadline)
                    .padding(12)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Dicas:").font(.headline)
                    tip("Leia o texto (ou o que você escreveu na sexta) em voz alta, algumas vezes.")
                    tip("Grave-se e ouça sua pronúncia, ritmo e entonação.")
                    tip("Depois, tente falar sobre o assunto de forma natural, sem ler.")
                }

                VStack(spacing: 14) {
                    Button {
                        if recorder.isRecording {
                            recorder.stopRecording()
                        } else {
                            recorder.requestPermissionAndRecord()
                        }
                    } label: {
                        Label(
                            recorder.isRecording ? "Parar gravação" : "Gravar minha fala",
                            systemImage: recorder.isRecording ? "stop.circle.fill" : "mic.circle.fill"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(recorder.isRecording ? .red : .accentColor)

                    if recorder.hasRecording {
                        Button {
                            recorder.isPlaying ? recorder.stopPlayback() : recorder.playback()
                        } label: {
                            Label(recorder.isPlaying ? "Parar" : "Ouvir minha gravação", systemImage: recorder.isPlaying ? "stop.fill" : "play.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }

                    if recorder.permissionDenied {
                        Text("Permissão de microfone negada. Ative em Ajustes do iOS, ou marque abaixo que praticou sem gravar.")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    Toggle("Pratiquei falando em voz alta (com ou sem gravar)", isOn: $practicedWithoutRecording)
                        .font(.caption)
                }
                .padding(12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .navigationTitle("Sábado")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            CompleteMissionButton(day: .saturday, isEnabled: recorder.hasRecording || practicedWithoutRecording)
        }
    }

    private func tip(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•")
            Text(text).font(.caption).foregroundStyle(.secondary)
        }
    }
}
