import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingSettings = false
    @State private var showingLevelChange = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    StreakXPBar(streak: progressStore.progress.currentStreak, xp: progressStore.progress.xpTotal)
                        .padding(.horizontal)

                    if let week = progressStore.progress.currentWeek {
                        WeekTextHeader(week: week)
                            .padding(.horizontal)

                        VStack(spacing: 12) {
                            ForEach(StudyDay.allCases) { day in
                                NavigationLink(value: day) {
                                    DayCardView(
                                        day: day,
                                        isCompleted: week.completedDays.contains(day),
                                        isNext: nextIncompleteDay(in: week) == day
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)

                        if week.isComplete {
                            weekCompleteBanner
                        }
                    } else if viewModel.isGenerating {
                        ProgressView("Gerando o texto da semana…")
                            .padding(.top, 60)
                    } else {
                        emptyStateStartWeek
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.orange)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("OneText")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingLevelChange = true
                    } label: {
                        Label(progressStore.progress.level?.displayName ?? "", systemImage: "chart.bar.fill")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .navigationDestination(for: StudyDay.self) { day in
                if let week = progressStore.progress.currentWeek {
                    DayMissionRouter(day: day, weeklyText: week.weeklyText)
                }
            }
            .sheet(isPresented: $showingSettings) { SettingsView() }
            .sheet(isPresented: $showingLevelChange) { LevelSelectionView(isOnboarding: false) }
            .task { await viewModel.ensureCurrentWeek(store: progressStore) }
        }
        .environmentObject(viewModel)
    }

    private func nextIncompleteDay(in week: WeekRecord) -> StudyDay? {
        StudyDay.allCases.first { !week.completedDays.contains($0) }
    }

    private var emptyStateStartWeek: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundStyle(.tint)
            Text("Pronto para começar a semana?")
                .font(.headline)
            Button {
                Task { await viewModel.startNextWeek(store: progressStore) }
            } label: {
                Label("Gerar texto da semana", systemImage: "wand.and.stars")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private var weekCompleteBanner: some View {
        VStack(spacing: 12) {
            Text("🎉 Semana concluída!")
                .font(.headline)
            Text("Você completou os 7 dias com este texto. Bora para o próximo?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                Task { await viewModel.startNextWeek(store: progressStore) }
            } label: {
                Label("Novo texto da semana", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

private struct WeekTextHeader: View {
    let week: WeekRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(week.weeklyText.topic.displayName.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(.tint)
            Text(week.weeklyText.title)
                .font(.title2.bold())
            ProgressView(value: week.progress)
                .tint(.accentColor)
            Text("\(week.completedDays.count) de 7 dias concluídos")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
