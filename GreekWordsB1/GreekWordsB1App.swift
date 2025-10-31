import SwiftUI
import SwiftData

@main
struct GreekWordsB1App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Word.self, GroupMeta.self, WordProgress.self, QuizStats.self])
        }
    }
}
