import SwiftUI
import SwiftData
import FSRS

enum ReviewState {
    case new
    case review
}

struct TrainingView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var isEnglish: Bool = Locale.preferredLanguages.first?.hasPrefix("en") == true
    @State private var dueWords: [Word] = []
    @State private var currentIndex = 0
    @State private var showTranslation = false
    @State private var finished = false
    @State private var noGroups = false
    @State private var todayNew = 0
    @State private var todayReview = 0
    @State private var wordStates: [String: ReviewState] = [:]

    private var todayTotal: Int {
        max(dueWords.count - currentIndex, 0)
    }

    private var buttonHeight: CGFloat {
        sizeClass == .regular ? 100 : 80
    }

    private var cornerRadius: CGFloat {
        sizeClass == .regular ? 40 : 30
    }

    private let scheduler = TrainingScheduler()

    var body: some View {
        ZStack {
            Color.gray.opacity(0.05).ignoresSafeArea()

            VStack {
                if noGroups {
                    Text("Нет открытых групп")
                        .font(.title2)
                        .glassLabel(height: sizeClass == .regular ? 90 : 70,
                                    cornerRadius: sizeClass == .regular ? 30 : 20)
                        .padding(.horizontal, 24)
                } else if finished {
                    Text("Все слова за сегодня пройдены!")
                        .font(.title2)
                        .glassLabel(height: sizeClass == .regular ? 90 : 70,
                                    cornerRadius: sizeClass == .regular ? 30 : 20)
                        .padding(.horizontal, 24)
                } else if let word = dueWords[safe: currentIndex] {
                    VStack(spacing: 40) {
                        if !dueWords.isEmpty {
                            VStack(spacing: 8) {
                                Text("Today: \(todayTotal) words")
                                    .font(.headline)

                                HStack(spacing: 12) {
                                    Text("New: \(todayNew)")
                                    Text("Review: \(todayReview)")
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .glassLabel(height: sizeClass == .regular ? 90 : 70,
                                        cornerRadius: sizeClass == .regular ? 30 : 20)
                            .padding(.top, 12)
                            .padding(.horizontal, 24)
                        }

                        Text(word.gr)
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)
                            .padding()
                            .glassCard(height: 120, cornerRadius: 30)
                            .padding(.horizontal, 24)
                            .padding(.top, 40)

                        if showTranslation {
                            Text(isEnglish ? word.en : word.ru)
                                .font(sizeClass == .regular ? .largeTitle : .title2)
                                .foregroundColor(.primary)
                                .transition(.opacity)
                        }

                        Spacer()

                        if showTranslation {
                            HStack(spacing: 12) {
                                ForEach(Rating.allCases.filter { $0 != .manual }, id: \.self) { rating in
                                    Button {
                                        Task { await handleRating(rating, for: word) }
                                    } label: {
                                        Text(rating.stringValue.capitalized)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .frame(maxWidth: .infinity)
                                            .glassCard(height: sizeClass == .regular ? 55 : 35,
                                                       cornerRadius: sizeClass == .regular ? 25 : 15)
                                    }
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.bottom, 40)
                        } else {
                            Button {
                                withAnimation { showTranslation = true }
                            } label: {
                                Text(Texts.showTranslation)
                                    .font(sizeClass == .regular ? .title : .title2)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.primary)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .glassCard(height: buttonHeight, cornerRadius: cornerRadius)
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 40)
                        }
                    }
                    .padding()
                    .animation(.easeInOut, value: showTranslation)
                } else {
                    ProgressView()
                }
            }
        }
        .task {
            await loadDueWords()
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Texts.training)
                    .font(sizeClass == .regular ? .largeTitle : .title2)
                    .foregroundColor(.primary)
            }
        }
    }

    // Loading words
    func loadDueWords() async {
        do {
            // Load groups
            let groups = try context.fetch(FetchDescriptor<GroupMeta>())
            let openIDs = groups.filter(\.opened).map(\.id)
            print("Open groups:", openIDs)

            // No open groups — exit
            guard !openIDs.isEmpty else {
                await MainActor.run {
                    self.noGroups = true
                    self.finished = false
                    self.dueWords = []
                }
                return
            }

            // Load words + filter by open groups
            let allWords = try context.fetch(FetchDescriptor<Word>())
            let wordsFromOpenGroups = allWords.filter { openIDs.contains($0.groupID) }
            print("Words from open groups:", wordsFromOpenGroups.count)

            // Load progress
            var progresses = try context.fetch(FetchDescriptor<WordProgress>())

            // Create WordProgress only for missing words
            let allowedIDs = Set(wordsFromOpenGroups.map(\.compositeID))
            let existingIDs = Set(progresses.map(\.compositeID))
            let missingIDs = allowedIDs.subtracting(existingIDs)

            if !missingIDs.isEmpty {
                for word in wordsFromOpenGroups where missingIDs.contains(word.compositeID) {
                    let progress = WordProgress(
                        compositeID: word.compositeID,
                        learned: false,
                        correctAnswers: 0,
                        seen: false
                    )
                    context.insert(progress)
                }

                try context.save()
                progresses = try context.fetch(FetchDescriptor<WordProgress>())
            }

            // Keep only progress for opened groups
            progresses = progresses.filter { allowedIDs.contains($0.compositeID) }

            // Get today's FSRS selection
            let todaysProgresses = scheduler.wordsForToday(from: progresses)
            let newCount = todaysProgresses.filter { $0.state == .new }.count
            let totalCount = todaysProgresses.count
            let reviewCount = totalCount - newCount
            wordStates = Dictionary(uniqueKeysWithValues: todaysProgresses.map { progress in
                let state: ReviewState = (progress.state == .new ? .new : .review)
                return (progress.compositeID, state)
            })

            // Convert progress → words
            dueWords = todaysProgresses.compactMap { progress in
                wordsFromOpenGroups.first { $0.compositeID == progress.compositeID }
            }
            print("Words selected for today:", dueWords.count)

            // Update UI
            await MainActor.run {
                currentIndex = 0
                showTranslation = false
                finished = dueWords.isEmpty
                todayNew = newCount
                todayReview = reviewCount
            }

        } catch {
            print("Error loading data:", error)
        }
    }

    func handleRating(_ rating: Rating, for word: Word) async {
        do {
            if let wordProgress = try context.fetch(FetchDescriptor<WordProgress>()).first(where: {
                $0.compositeID == word.compositeID }) {
                let updated = scheduler.nextReview(for: wordProgress, rating: rating)
                context.insert(updated)
                try context.save()
            }

            withAnimation {
                if currentIndex + 1 < dueWords.count {
                    currentIndex += 1
                    showTranslation = false
                } else {
                    finished = true
                }

                if let state = wordStates[word.compositeID] {
                    switch state {
                    case .new:
                        todayNew -= 1
                    case .review:
                        todayReview -= 1
                    }
                }
            }

        } catch {
            print("Review error: \(error)")
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
