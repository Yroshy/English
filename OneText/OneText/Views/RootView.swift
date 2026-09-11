import SwiftUI

struct RootView: View {
    @EnvironmentObject private var progressStore: ProgressStore

    var body: some View {
        Group {
            if progressStore.progress.hasOnboarded, progressStore.progress.level != nil {
                MainTabView()
            } else {
                LevelSelectionView(isOnboarding: true)
            }
        }
        .onAppear { progressStore.evaluateStreakDecay() }
    }
}

private struct MainTabView: View {
    @EnvironmentObject private var progressStore: ProgressStore

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Semana", systemImage: "text.book.closed.fill") }

            ReviewView()
                .tabItem { Label("Revisão", systemImage: "rectangle.stack.fill") }
                .badge(progressStore.dueReviewCardCount)
        }
    }
}
