import SwiftUI
import SwiftData

struct GroupsListView: View {
    let mode: QuizMode
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

    init(mode: QuizMode = .direct) {
        self.mode = mode
    }

    var body: some View {
        let wordsByGroup = Dictionary(grouping: words, by: \.groupID)
        let seenIDs = Set(progresses.filter { $0.seen }.map(\.compositeID))

        ZStack {
            Color.gray.opacity(0.05)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(groups) { group in
                        NavigationLink(destination: destination(for: group)) {
                            let counts = countForGroup(group, wordsByGroup: wordsByGroup, seenIDs: seenIDs)
                            let counterText = "\(counts.seen)/\(counts.total)"
                            let title = isEnglish ? group.nameEn : group.nameRu
                            let dynamicHeight = dynamicCardHeight(for: title, counterText: counterText)

                            HStack(alignment: .center) {
                                Text(title)
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
                            .frame(height: dynamicHeight, alignment: .center)
                            .glassCard(height: dynamicHeight, cornerRadius: cornerRadius)
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

    private func dynamicCardHeight(for title: String, counterText: String) -> CGFloat {
        guard sizeClass != .regular else { return cardHeight }

        let font = UIFont.preferredFont(forTextStyle: .title3)
        let screenWidth = UIScreen.main.bounds.width

        let outerHPadding = paddingHorizontal * 2
        let innerHPadding: CGFloat = 40
        let spacing: CGFloat = 8

        let counterWidth = textWidth(counterText, font: font)
        let availableWidth = max(0, screenWidth - outerHPadding - innerHPadding - spacing - counterWidth)

        let textHeight = textHeight(title, font: font, width: availableWidth)
        let lineHeight = max(font.lineHeight, 1)
        let isThreeLines = textHeight > lineHeight * 2.8

        return isThreeLines ? 90 : cardHeight
    }

    private func textHeight(_ text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let rect = (text as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return ceil(rect.height)
    }

    private func textWidth(_ text: String, font: UIFont) -> CGFloat {
        let rect = (text as NSString).boundingRect(
            with: CGSize(width: .greatestFiniteMagnitude, height: font.lineHeight),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return ceil(rect.width)
    }

    private func countForGroup(_ group: GroupMeta,
                               wordsByGroup: [Int: [Word]],
                               seenIDs: Set<String>) -> (seen: Int, total: Int) {
        let groupWords = wordsByGroup[group.id] ?? []
        let seen = groupWords.reduce(into: 0) { result, word in
            if seenIDs.contains(word.compositeID) {
                result += 1
            }
        }
        return (seen, groupWords.count)
    }

    @ViewBuilder
    private func destination(for group: GroupMeta) -> some View {
        QuizView(group: group, mode: mode)
    }
}
