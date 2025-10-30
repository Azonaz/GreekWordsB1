import SwiftUI
import SwiftData

struct GroupsListView: View {
    @Query(sort: \GroupMeta.nameEn) private var groups: [GroupMeta]
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.dismiss) private var dismiss

    private var cardHeight: CGFloat {
        sizeClass == .regular ? 70 : 50
    }

    private var cornerRadius: CGFloat {
        sizeClass == .regular ? 30 : 20
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
                            Text(isEnglish ? group.nameEn : group.nameRu)
                                .font(sizeClass == .regular ? .title2 : .title3)
                                .foregroundColor(.primary)
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
