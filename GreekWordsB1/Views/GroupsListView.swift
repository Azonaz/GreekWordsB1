import SwiftUI
import SwiftData

struct GroupsListView: View {
    @Query(sort: [SortDescriptor(\GroupMeta.id, order: .forward)]) private var groups: [GroupMeta]
    @Query private var words: [Word]
    @Query private var progresses: [WordProgress]
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    private var cardHeight: CGFloat {
        sizeClass == .regular ? 100 : 70
    }

    private var cornerRadius: CGFloat {
        sizeClass == .regular ? 40 : 30
    }

    private var paddingHorizontal: CGFloat {
        sizeClass == .regular ? 48 : 24
    }

    private var isEnglish: Bool {
        Locale.preferredLanguages.first?.hasPrefix("en") == true
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.05)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(groups) { group in
                        NavigationLink(destination: QuizView(group: group)) {

                            let title = Text(isEnglish ? group.nameEn : group.nameRu)
                                .font(sizeClass == .regular ? .title2 : .title3)
                                .foregroundColor(.primary)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)

                            let counts = countForGroup(group)
                            let counterText = "\(counts.seen)/\(counts.total)"
                            let base = UIColor(red: 162/255, green: 24/255, blue: 29/255, alpha: 1.0)

                            let counter = StrokeText(
                                text: counterText,
                                fontSize: cardHeight * 0.70,
                                weight: .heavy,
                                fillColor: base.withAlphaComponent(colorScheme == .dark ? 0.4 : 0.07),
                                strokeColor: base.withAlphaComponent(colorScheme == .dark ? 0.5 : 0.09),
                                strokeWidth: 2.0,
                                kerning: sizeClass == .regular ? 4.0 : 2.0
                            )
                            .frame(height: cardHeight)
                            .offset(y: cardHeight * 0.06)
                            .padding(.horizontal, 20)

                            title
                                .frame(height: cardHeight)
                                .overlay(
                                    counter,
                                    alignment: .trailing
                                )
                                .glassCard(height: cardHeight, cornerRadius: cornerRadius)
                                .padding(.horizontal, paddingHorizontal)
                        }
                    }
                }
                .padding(.top, sizeClass == .regular ? 60 : 40)
            }
        }
        .background(
            Image(.pillar)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.2)
        )
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Texts.categories)
                    .font(sizeClass == .regular ? .largeTitle : .title2)
                    .foregroundColor(.primary)
            }
        }
    }

    private func countForGroup(_ group: GroupMeta) -> (seen: Int, total: Int) {
        let groupWords = words.filter { $0.groupID == group.id }
        let total = groupWords.count

        let seen = groupWords.reduce(into: 0) { result, word in
            if progresses.first(where: { $0.compositeID == word.compositeID })?.seen == true {
                result += 1
            }
        }

        return (seen, total)
    }
}

#Preview {
    let schema = Schema([GroupMeta.self, Word.self, WordProgress.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

    guard let container = try? ModelContainer(for: schema, configurations: [config]) else {
        return Text("Container creation error")
    }

    let ctx = ModelContext(container)
    ctx.insert(GroupMeta(id: 1, version: 1, nameEn: "Meeting", nameRu: "Встреча"))
    ctx.insert(GroupMeta(id: 2, version: 1, nameEn: "Family", nameRu: "Семья"))
    ctx.insert(GroupMeta(id: 3, version: 2, nameEn: "Travel", nameRu: "Путешествия"))

    return NavigationStack {
        GroupsListView()
    }
    .modelContainer(container)
}
