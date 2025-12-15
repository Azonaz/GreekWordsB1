import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var trainingAccess: TrainingAccessManager
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    @State private var goTraining = false
    @State private var goPaywall = false

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

                    NavigationLink(destination: GroupsListView(mode: .reverse)) {
                        Text(Texts.reverseQuiz)
                            .foregroundColor(.primary)
                            .glassCard(height: buttonHeight, cornerRadius: cornerRadius)
                    }
                    .padding(.top, topPadding)
                    .padding(.horizontal, buttonPaddingHorizontal)

                    Button {
                        trainingAccess.startTrialIfNeeded()
                        trainingAccess.refreshState()

                        if trainingAccess.hasAccess {
                            goTraining = true
                        } else {
                            goPaywall = true
                        }
                    } label: {
                        Text(Texts.training)
                            .foregroundColor(.primary)
                            .glassCard(height: buttonHeight, cornerRadius: cornerRadius)
                    }
                    .padding(.top, topPadding)
                    .padding(.horizontal, buttonPaddingHorizontal)
                    .navigationDestination(isPresented: $goTraining) {
                        TrainingView()
                    }
                    .navigationDestination(isPresented: $goPaywall) {
                        TrainingPaywallView()
                    }

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
                _ = try? context.fetch(FetchDescriptor<GroupMeta>())
            }
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    Task { await syncVocabulary() }
                }
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
