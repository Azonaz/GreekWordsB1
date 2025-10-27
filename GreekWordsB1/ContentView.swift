import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @State private var showCategories = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Greek Words")
                    .font(.largeTitle)
                
                Button("Show Categories") {
                    showCategories = true
                }
                .buttonStyle(.borderedProminent)
                .padding()
                
                Spacer()
            }
            .navigationDestination(isPresented: $showCategories) {
                GroupsListView()
            }
            .task {
                await syncVocabulary()
            }
        }
    }
    
    func syncVocabulary() async {
        do {
            let url = URL(string: "https://azonaz.github.io/words-gr-b1.json")!
            let service = VocabularySyncService(context: context, remoteURL: url)
            try await service.syncVocabulary()
        } catch {
            print("Synchronisation error: \(error)")
        }
    }
}
