import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @State private var showCategories = false
    @Environment(\.horizontalSizeClass) var sizeClass
    
    private var buttonHeight: CGFloat {
        sizeClass == .regular ? 100 : 80
    }
    
    private var buttonPaddingHorizontal: CGFloat {
        sizeClass == .regular ? 100 : 60
    }
    
    private var topPadding: CGFloat {
        sizeClass == .regular ? 40 : 20
    }
    
    private var cornerRadius: CGFloat {
        sizeClass == .regular ? 30 : 20
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.pink.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("Greek Words A2")
                        .font(sizeClass == .regular ? .largeTitle : .title)
                        .fontWeight(.semibold)
                        .padding(.top, topPadding)
                    
                    Spacer()
                    
                    NavigationLink(destination: GroupsListView()) {
                        Text("Quiz")
                            .foregroundColor(.primary)
                            .glassCard(height: buttonHeight, cornerRadius: cornerRadius, padding: buttonPaddingHorizontal)
                    }
                    
                    Text("Coming soon")
                        .glassCard(height: buttonHeight, cornerRadius: cornerRadius, padding: buttonPaddingHorizontal)
                    
                    Spacer()
                }
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

#Preview {
    ContentView()
        .modelContainer(for: [Word.self, GroupMeta.self, WordProgress.self])
}
