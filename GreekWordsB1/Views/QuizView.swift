import SwiftUI
import SwiftData

struct QuizView: View {
    let group: GroupMeta
    @Query var words: [Word]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var quizWords: [Word] = []
    @State private var currentIndex = 0
    @State private var options: [Word] = []
    @State private var selectedWord: Word?
    @State private var isCorrect: Bool?
    @State private var correctCount = 0
    @State private var showResult = false
    @State private var isEnglish: Bool = Locale.preferredLanguages.first?.hasPrefix("en") == true
    @AppStorage("isBlurEnabled") private var isBlurEnabled = true
    @State private var answersBlurred = false
    @State private var haptic = UISelectionFeedbackGenerator()
    @State private var shakeOffset: CGFloat = 0
    @State private var answeredCount = 0
    @State private var isInteractionDisabled = false

    private var currentWord: Word? {
        quizWords.isEmpty ? nil : quizWords[currentIndex]
    }

    private var paddingHorizontal: CGFloat {
        sizeClass == .regular ? 100 : 60
    }

    private var cornerRadius: CGFloat {
        sizeClass == .regular ? 40 : 30
    }

    init(group: GroupMeta) {
        self.group = group
        let groupID = group.id
        _words = Query(filter: #Predicate<Word> { $0.groupID == groupID })
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.05).ignoresSafeArea()

            VStack(spacing: 100) {
                if let currentWord {
                    Text(currentWord.gr)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                        .padding()
                        .glassCard(height: sizeClass == .regular ? 140 : 120, cornerRadius: cornerRadius)
                        .padding(.horizontal, paddingHorizontal)

                    VStack(spacing: 20) {
                        ForEach(options, id: \.compositeID) { word in
                            Text(isEnglish ? word.en : word.ru)
                                .offset(x: (isCorrect == false && word.compositeID ==
                                            selectedWord?.compositeID) ? shakeOffset : 0)
                                .font(.title3)
                                .foregroundColor(.primary)
                                .blur(radius: answersBlurred ? 8 : 0)
                                .opacity(answersBlurred ? 0.9 : 1)
                                .animation(.easeInOut(duration: 0.3), value: answersBlurred)
                                .glassCard(
                                    height: sizeClass == .regular ? 80 : 60,
                                    cornerRadius: cornerRadius,
                                    highlightColors: highlightColors(for: word)
                                )
                                .padding(.horizontal, paddingHorizontal)
                                .onTapGesture {
                                    if !answersBlurred && !isInteractionDisabled {
                                        handleTap(word)
                                    }
                                }
                        }
                    }
                } else {
                    ProgressView()
                }

                GlassProgressBar(progress: Double(answeredCount) / Double(max(quizWords.count, 1)))
            }
        }
        .onAppear {
            haptic.prepare()
            startQuiz()
        }
        .alert(isPresented: $showResult) {
            Alert(
                title: Text(Texts.result),
                message: Text("\(correctCount)/\(quizWords.count)"),
                primaryButton: .default(Text(Texts.restart)) {
                    startQuiz()
                },
                secondaryButton: .cancel(Text(Texts.back)) {
                    dismiss()
                }
            )
        }
        .onChange(of: showResult) {
            if showResult {
                saveQuizResult()
            }
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(isEnglish ? group.nameEn : group.nameRu)
                    .font(sizeClass == .regular ? .largeTitle : .title2)
                    .foregroundColor(.primary)
            }
        }
    }

    private func startQuiz() {
        guard words.count >= 10 else { return }
        quizWords = Array(words.shuffled().prefix(10))
        currentIndex = 0
        correctCount = 0
        answeredCount = 0
        selectedWord = nil
        isCorrect = nil
        showResult = false
        setupRound()
    }

    private func setupRound() {
        guard let currentWord else { return }
        let others = words.filter { $0.compositeID != currentWord.compositeID }.shuffled()
        let newOptions = ([currentWord] + others.prefix(2)).shuffled()

        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            options = newOptions
            answersBlurred = isBlurEnabled
        }
    }

    private func handleTap(_ word: Word) {
        guard selectedWord == nil else { return }
        isInteractionDisabled = true

        selectedWord = word
        let correct = (word.compositeID == currentWord?.compositeID)
        isCorrect = correct
        if correct { correctCount += 1 } else { shake() }

        haptic.selectionChanged()
        haptic.prepare()

        withAnimation(.easeInOut(duration: 0.35)) {
            answeredCount += 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                selectedWord = nil
                isCorrect = nil

                if currentIndex + 1 < quizWords.count {
                    currentIndex += 1
                    setupRound()
                } else {
                    showResult = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                isInteractionDisabled = false
            }
        }
    }

    private func saveQuizResult() {
        let result = Int((Double(correctCount) / Double(quizWords.count)) * 100)

        if let stats = try? context.fetch(FetchDescriptor<QuizStats>()).first {
            stats.completedCount += 1
            stats.totalScore += result
        } else {
            context.insert(QuizStats(completedCount: 1, totalScore: result))
        }

        for word in quizWords {
            let id = word.compositeID
            let descriptor = FetchDescriptor<WordProgress>(
                predicate: #Predicate { $0.compositeID == id }
            )

            if let wordProgress = try? context.fetch(descriptor).first {
                wordProgress.seen = true
            } else {
                context.insert(WordProgress(compositeID: id, seen: true))
            }
        }

        do {
            try context.save()
        } catch {
            print("Error saving statistics: \(error)")
        }
    }

    private func highlightColors(for word: Word) -> [Color]? {
        guard let selectedWord else { return nil }
        if word.compositeID != selectedWord.compositeID { return nil }
        return isCorrect == true
        ? [.green.opacity(0.4), .green.opacity(0.7), .green.opacity(0.4)]
        : [.red.opacity(0.4), .red.opacity(0.8), .red.opacity(0.4)]
    }

    private func shake() {
        let amplitude: CGFloat = 8
        withAnimation(.default.speed(3)) {
            shakeOffset = amplitude
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.default.speed(3)) { shakeOffset = -amplitude }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.default.speed(3)) { shakeOffset = amplitude / 2 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.default.speed(3)) { shakeOffset = 0 }
        }
    }
}

#Preview {
    let schema = Schema([GroupMeta.self, Word.self, WordProgress.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

    guard let container = try? ModelContainer(for: schema, configurations: [config]) else {
        return Text("Container creation error")
    }

    let context = ModelContext(container)

    let mockGroup = GroupMeta(id: 1, version: 1, nameEn: "Family", nameRu: "Семья")
    context.insert(mockGroup)

    let mockWords = [
        Word(localID: 1, groupID: 1, gr: "μητέρα", en: "mother", ru: "мама"),
        Word(localID: 2, groupID: 1, gr: "πατέρας", en: "father", ru: "папа"),
        Word(localID: 3, groupID: 1, gr: "αδελφός", en: "brother", ru: "брат"),
        Word(localID: 4, groupID: 1, gr: "αδελφή", en: "sister", ru: "сестра"),
        Word(localID: 5, groupID: 1, gr: "γιος", en: "son", ru: "сын"),
        Word(localID: 6, groupID: 1, gr: "κόρη", en: "daughter", ru: "дочь")
    ]
    mockWords.forEach { context.insert($0) }

    do {
        try context.save()
    } catch {
        print("Context saving error: \(error)")
    }

    return NavigationStack {
        QuizView(group: mockGroup)
    }
    .modelContainer(container)
}
