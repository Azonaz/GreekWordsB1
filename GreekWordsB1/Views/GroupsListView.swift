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
                            let counts = countForGroup(group)
                            let counterText = "\(counts.seen)/\(counts.total)"

                            HStack(alignment: .center) {
                                Text(isEnglish ? group.nameEn : group.nameRu)
                                    .font(sizeClass == .regular ? .title2 : .title3)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(counterText)
                                    .font(sizeClass == .regular ? .title2 : .title3)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .frame(height: cardHeight)
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
