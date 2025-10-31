import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Query private var quizStats: [QuizStats]
    @Query private var words: [Word]
    @Query private var progress: [WordProgress]
    @Environment(\.horizontalSizeClass) var sizeClass

    private var totalWords: Int { words.count }
    private var seenWords: Int { progress.filter { $0.seen }.count }
    private var learnedWords: Int { progress.filter { $0.learned }.count }
    private var completedQuizzes: Int { quizStats.first?.completedCount ?? 0 }
    private var averageScore: Int { Int(quizStats.first?.averageScore ?? 0) }

    private var cardHeight: CGFloat {
        sizeClass == .regular ? 90 : 70
    }

    private var cornerRadius: CGFloat {
        sizeClass == .regular ? 30 : 20
    }

    private var horizontalPadding: CGFloat {
        sizeClass == .regular ? 80 : 40
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.05).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    Text(Texts.quiz)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    VStack(spacing: 16) {
                        StatCard(title: Texts.allWords, value: "\(totalWords)")
                        StatCard(title: Texts.quizzesCompleted, value: "\(completedQuizzes)")
                        StatCard(title: Texts.wordsSeen, value: "\(seenWords)")
                        StatCard(title: Texts.averagePercentage, value: "\(averageScore)%")
                    }
                    .padding(.horizontal, horizontalPadding)
                }
                .padding(.top, 24)
            }
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Texts.statistics)
                    .font(sizeClass == .regular ? .largeTitle : .title2)
                    .foregroundColor(.primary)
            }
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    @Environment(\.horizontalSizeClass) var sizeClass

    private var cornerRadius: CGFloat {
        sizeClass == .regular ? 30 : 20
    }

    private var height: CGFloat {
        sizeClass == .regular ? 90 : 70
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .glassLabel(height: height, cornerRadius: cornerRadius)
    }
}

#Preview {
    StatisticsView()
}
