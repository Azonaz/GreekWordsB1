import SwiftUI
import SwiftData

struct QuizView: View {
    let group: GroupMeta
    @Query var words: [Word]
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @State private var currentWord: Word?
    @State private var options: [Word] = []
    @State private var selectedWord: Word?
    @State private var isCorrect: Bool?
    @State private var isEnglish: Bool = Locale.preferredLanguages.first?.hasPrefix("en") == true
    
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
                                .font(.title3)
                                .foregroundColor(.primary)
                                .glassCard(
                                    height: sizeClass == .regular ? 80 : 60,
                                    cornerRadius: cornerRadius,
                                    highlightColors: highlightColors(for: word)
                                )
                                .padding(.horizontal, paddingHorizontal)
                                .onTapGesture { handleTap(word) }
                        }
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .onAppear(perform: setupRound)
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(isEnglish ? group.nameEn : group.nameRu)
                    .font(sizeClass == .regular ? .largeTitle : .title2)
                    .foregroundColor(.primary)
            }
        }
    }
 
    private func handleTap(_ word: Word) {
        guard selectedWord == nil else { return }
        selectedWord = word
        isCorrect = (word.compositeID == currentWord?.compositeID)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation {
                selectedWord = nil
                isCorrect = nil
                setupRound()
            }
        }
    }
    
    private func highlightColors(for word: Word) -> [Color]? {
        guard let selectedWord else { return nil }
        if word.compositeID != selectedWord.compositeID { return nil }
        return isCorrect == true ? [.green.opacity(0.4), .green.opacity(0.7), .green.opacity(0.4)] : [.red.opacity(0.4), .red.opacity(0.8), .red.opacity(0.4)]
    }

    private func setupRound() {
        guard words.count >= 3 else { return }
        
        let mainWord = words.randomElement()!
        let others = words.filter { $0.compositeID != mainWord.compositeID }
        let randomOptions = others.shuffled().prefix(2)

        options = ([mainWord] + randomOptions).shuffled()
        currentWord = mainWord
    }
}

#Preview {
    let schema = Schema([GroupMeta.self, Word.self, WordProgress.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = ModelContext(container)

    let mockGroup = GroupMeta(id: 1, version: 1, nameEn: "Family", nameRu: "Семья")
    context.insert(mockGroup)

    let mockWords = [
        Word(localID: 1, groupID: 1, gr: "μητέρα",  en: "mother",  ru: "мама"),
        Word(localID: 2, groupID: 1, gr: "πατέρας", en: "father",  ru: "папа"),
        Word(localID: 3, groupID: 1, gr: "αδελφός", en: "brother", ru: "брат"),
        Word(localID: 4, groupID: 1, gr: "αδελφή",  en: "sister",  ru: "сестра"),
        Word(localID: 5, groupID: 1, gr: "γιος",    en: "son",     ru: "сын"),
        Word(localID: 6, groupID: 1, gr: "κόρη",    en: "daughter",ru: "дочь")
    ]
    mockWords.forEach { context.insert($0) }

    try! context.save()

    return NavigationStack {
        QuizView(group: mockGroup)
    }
    .modelContainer(container)
}
