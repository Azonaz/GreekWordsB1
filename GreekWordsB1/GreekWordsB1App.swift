import SwiftUI
import SwiftData

@main
struct GreekWordsB1App: App {
    @State private var showLaunchScreen = true
    @StateObject private var trainingAccess = TrainingAccessManager()

    var body: some Scene {
        WindowGroup {
            if showLaunchScreen {
                LaunchScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                showLaunchScreen = false
                            }
                        }
                    }
            } else {
                ContentView()
                    .environmentObject(trainingAccess)
                    .modelContainer(for: [Word.self, GroupMeta.self, WordProgress.self, QuizStats.self])
            }
        }
    }
}
