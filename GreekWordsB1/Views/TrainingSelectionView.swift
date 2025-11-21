import SwiftUI
import FSRS
import SwiftData

struct TrainingSelectionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.verticalSizeClass) var vSizeClass

    let wordsProgress: [WordProgress]
    let title: String

    @State private var weakWords: [Word] = []
    @State private var currentIndex: Int = 0
    @State private var showTranslation = false
    @State private var finished = false
    @State private var isEnglish: Bool = Locale.preferredLanguages.first?.hasPrefix("en") == true

    private var currentWord: Word? {
        weakWords[safe: currentIndex]
    }

    private var buttonHeight: CGFloat {
        hSizeClass == .regular ? 100 : 80
    }

    private var cornerRadius: CGFloat {
        hSizeClass == .regular ? 40 : 30
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.05).ignoresSafeArea()

            VStack {
                if finished {
                    Text(Texts.done)
                        .multilineTextAlignment(.center)
                        .padding()
                        .glassLabel(
                            height: hSizeClass == .regular ? 120 : 80,
                            cornerRadius: cornerRadius
                        )
                        .padding(.horizontal, 16)

                } else if let word = currentWord {
                    trainingLayout(for: word)

                } else {
                    ProgressView()
                }
            }
        }
        .task {
            await loadWords()
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(hSizeClass == .regular ? .largeTitle : .title2)
            }
        }
    }

    @ViewBuilder
    private func trainingLayout(for word: Word) -> some View {
        VStack(spacing: 40) {
            Text("\(weakWords.count - currentIndex) слов осталось")
                .font(.headline)
                .glassLabel(
                    height: hSizeClass == .regular ? 70 : 60,
                    cornerRadius: cornerRadius
                )
                .padding(.horizontal, 16)
                .padding(.top, 12)

            Text(word.gr)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding()
                .glassCard(height: hSizeClass == .regular ? 140 : 120,
                           cornerRadius: cornerRadius)
                .padding(.horizontal, 16)
                .padding(.top, 20)

            if showTranslation {
                Text(isEnglish ? word.en : word.ru)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
                    .padding(.horizontal, 16)
            }

            Spacer()

            if showTranslation {
                ratingButtons(for: word)
            } else {
                Button {
                    withAnimation { showTranslation = true }
                } label: {
                    Text(Texts.showTranslation)
                        .font(hSizeClass == .regular ? .title : .title2)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .glassCard(height: buttonHeight,
                                   cornerRadius: cornerRadius)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 36)
            }
        }
        .padding()
    }

    @ViewBuilder
    private func ratingButtons(for word: Word) -> some View {
        HStack(spacing: 12) {
            ForEach(Rating.allCases.filter { $0 != .manual }, id: \.self) { rating in
                Button {
                    Task { await handleRating(rating, for: word) }
                } label: {
                    Text(rating.localized)
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .glassCard(height: hSizeClass == .regular ? 55 : 40,
                                   cornerRadius: hSizeClass == .regular ? 25 : 15)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 40)
    }

    private func loadWords() async {
        do {
            let allWords = try context.fetch(FetchDescriptor<Word>())

            // match WordProgress → Word
            let ids = Set(wordsProgress.map(\.compositeID))
            self.weakWords = allWords.filter { ids.contains($0.compositeID) }

            await MainActor.run {
                currentIndex = 0
                showTranslation = false
                finished = weakWords.isEmpty
            }

        } catch {
            print("TrainingSelectionView loadWords error:", error)
        }
    }

    private func handleRating(_ rating: Rating, for word: Word) async {
        do {
            if let wProgress = try context
                .fetch(FetchDescriptor<WordProgress>())
                .first(where: { $0.compositeID == word.compositeID }) {
                let scheduler = TrainingScheduler()
                let updated = scheduler.nextReview(for: wProgress, rating: rating)
                context.insert(updated)
                try context.save()
            }

            withAnimation {
                if currentIndex + 1 < weakWords.count {
                    currentIndex += 1
                    showTranslation = false
                } else {
                    finished = true
                }
            }

        } catch {
            print("TrainingSelectionView handleRating error:", error)
        }
    }
}
