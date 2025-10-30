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
                Color.gray.opacity(0.05)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Greek Words B1")
                        .font(sizeClass == .regular ? .largeTitle : .title)
                        .fontWeight(.semibold)
                        .padding(.top, topPadding)
                    
                    Spacer()
                    
                    NavigationLink(destination: GroupsListView()) {
                        Text(Texts.quiz)
                            .foregroundColor(.primary)
                            .glassCard(height: buttonHeight, cornerRadius: cornerRadius)
                    }
                    .padding(.horizontal, buttonPaddingHorizontal)
                    
                    Text(Texts.soon)
                        .glassCard(height: buttonHeight, cornerRadius: cornerRadius)
                        .padding(.top, topPadding)
                        .padding(.horizontal, buttonPaddingHorizontal)
                    
                    Spacer()
                    
                    HStack(spacing: 24) {
                        Button {
                            print("Info tapped")
                        } label: {
                            Image(systemName: "info.circle")
                                .font(.system(size: 24, weight: .regular))
                                .frame(maxWidth: .infinity)
                                .glassCard(height: 55, cornerRadius: 25)
                        }
                        
                        Button {
                            print("Statistics tapped")
                        } label: {
                            Image(systemName: "chart.pie")
                                .font(.system(size: 24, weight: .regular))
                                .frame(maxWidth: .infinity)
                                .glassCard(height: 55, cornerRadius: 25)
                        }
                        
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gear")
                                .font(.system(size: 24, weight: .regular))
                                .frame(maxWidth: .infinity)
                                .glassCard(height: 55, cornerRadius: 25)
                        }
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, buttonPaddingHorizontal)
                    .padding(.bottom, 20)
                }
            }
            .background(
                Image(.pillar)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.2)
            )
            .task {
                await syncVocabulary()
            }
        }
    }
    
    func syncVocabulary() async {
        do {
            let url = URL(string: baseURL)!
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
