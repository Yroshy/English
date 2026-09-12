import SwiftUI

@main
struct OneTextApp: App {
    @StateObject private var progressStore = ProgressStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(progressStore)
        }
    }
}
