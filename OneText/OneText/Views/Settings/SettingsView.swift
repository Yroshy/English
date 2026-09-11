import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @Environment(\.dismiss) private var dismiss

    @State private var apiKey: String = APIKeyStore.load() ?? ""
    @State private var savedConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(progressStore.progress.level?.displayName ?? "—")
                        .font(.title2.bold())
                    Text(progressStore.progress.level?.title ?? "")
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Seu nível atual")
                }

                Section {
                    SecureField("sk-ant-...", text: $apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Button("Salvar chave") {
                        APIKeyStore.save(apiKey)
                        savedConfirmation = true
                    }
                    if !apiKey.isEmpty {
                        Button("Remover chave", role: .destructive) {
                            APIKeyStore.delete()
                            apiKey = ""
                        }
                    }
                } header: {
                    Text("Chave de API da Anthropic (opcional)")
                } footer: {
                    Text("Com uma chave, o OneText gera automaticamente novos textos de rotina, collocations extras e correções de escrita usando IA. Sem chave, o app usa os textos offline já incluídos. Sua chave fica salva só neste dispositivo (Keychain).")
                }

                Section {
                    HStack {
                        Text("Sequência atual")
                        Spacer()
                        Text("\(progressStore.progress.currentStreak) dias")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Maior sequência")
                        Spacer()
                        Text("\(progressStore.progress.longestStreak) dias")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("XP total")
                        Spacer()
                        Text("\(progressStore.progress.xpTotal)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Semanas concluídas")
                        Spacer()
                        Text("\(progressStore.progress.weeksCompletedCount)")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Seu progresso")
                }
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
            .alert("Chave salva!", isPresented: $savedConfirmation) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}
