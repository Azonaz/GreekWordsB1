import SwiftUI
import SwiftData
import FSRS

struct TrainingView: View {
    @Environment(\.modelContext) private var context

    @State private var dueWords: [Word] = []
    @State private var currentIndex = 0
    @State private var showTranslation = false
    @State private var finished = false
    @State private var todayTotal = 0
    @State private var todayNew = 0
    @State private var todayReview = 0

    private let scheduler = TrainingScheduler()

    var body: some View {
        VStack {
            if finished {
                Text("All words for today have been reviewed!")
                    .font(.title2)
                    .padding()
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
                        .padding(.top, 12)
                    }

                    Text(word.gr)
                        .font(.system(size: 44, weight: .bold))
                        .padding(.top, 60)

                    if showTranslation {
                        VStack(spacing: 12) {
                            Text(word.en)
                                .font(.title3)
                            Text(word.ru)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .transition(.opacity)
                    }

                    Spacer()

                    if showTranslation {
                        HStack(spacing: 16) {
                            ForEach(Rating.allCases.filter { $0 != .manual }, id: \.self) { rating in
                                Button(rating.stringValue.capitalized) {
                                    Task { await handleRating(rating, for: word) }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding(.bottom, 40)
                    } else {
                        Button("Show translation") {
                            withAnimation { showTranslation = true }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.bottom, 40)
                    }
                }
                .padding()
                .animation(.easeInOut, value: showTranslation)
            } else {
                ProgressView()
            }
        }
        .task {
            await loadDueWords()
        }
        .navigationTitle(Texts.training)
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
                    self.dueWords = []
                    self.currentIndex = 0
                    self.showTranslation = false
                    self.finished = true
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
                todayTotal = totalCount
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
