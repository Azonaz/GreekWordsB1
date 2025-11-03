import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @State private var showCategories = false
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.colorScheme) var colorScheme

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
        sizeClass == .regular ? 40 : 30
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.05)
                    .ignoresSafeArea()

                VStack(spacing: 10) {
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

                    ZStack(alignment: .bottomTrailing) {
                        Text(Texts.training)
                            .glassCard(height: buttonHeight, cornerRadius: cornerRadius)
                            .overlay(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors:
                                                    colorScheme == .dark
                                                    ? [
                                                        Color.white.opacity(0.10),
                                                        Color.white.opacity(0.45)
                                                    ]
                                                    : [
                                                        Color.white.opacity(0.30),
                                                        Color.black.opacity(0.05)
                                                    ]
                                                ),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .background(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .strokeBorder(
                                                    .darkRed,
                                                    lineWidth: 0.6
                                                )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .frame(width: 120, height: 38)
                                        .overlay(
                                            Text(Texts.soon)
                                                .font(.headline.weight(.semibold))
                                                .foregroundColor(.darkRed)
                                                .shadow(color: Color.darkRed.opacity(0.7), radius: 4)
                                                .shadow(color: Color.white.opacity(colorScheme == .dark ? 0.4 : 0.2),
                                                        radius: 1)
                                        )
                                        .rotationEffect(.degrees(-10))
                                        .offset(x: 10, y: 8)
                                },
                                alignment: .bottomTrailing
                            )
                    }
                    .padding(.top, topPadding)
                    .padding(.horizontal, buttonPaddingHorizontal)

                    Spacer()

                    HStack(spacing: 24) {
                        NavigationLink {
                            InfoView()
                        } label: {
                            Image(systemName: "info.circle")
                                .font(.system(size: 24, weight: .regular))
                                .frame(maxWidth: .infinity)
                                .glassCard(height: 55, cornerRadius: 25)
                        }

                        NavigationLink {
                            StatisticsView()
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
        .modelContainer(for: [Word.self, GroupMeta.self, WordProgress.self, QuizStats.self])
}
