import SwiftUI

struct LevelSelectionView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @Environment(\.dismiss) private var dismiss
    let isOnboarding: Bool

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if isOnboarding {
                        VStack(spacing: 8) {
                            Image(systemName: "text.book.closed.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(.tint)
                            Text("OneText")
                                .font(.largeTitle.bold())
                            Text("Um único texto por semana. Sete dias, todas as habilidades.\nQual é o seu nível de inglês?")
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 24)
                    }

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(CEFRLevel.allCases) { level in
                            Button {
                                selectLevel(level)
                            } label: {
                                LevelCard(level: level)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 24)
            }
            .navigationTitle(isOnboarding ? "" : "Alterar nível")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isOnboarding {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") { dismiss() }
                    }
                }
            }
        }
    }

    private func selectLevel(_ level: CEFRLevel) {
        if isOnboarding {
            progressStore.completeOnboarding(level: level)
        } else {
            progressStore.changeLevel(to: level)
            dismiss()
        }
    }
}

private struct LevelCard: View {
    let level: CEFRLevel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(level.displayName)
                .font(.title2.bold())
            Text(level.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.tint)
            Text(level.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .frame(minHeight: 140)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.tint.opacity(0.25), lineWidth: 1))
    }
}
