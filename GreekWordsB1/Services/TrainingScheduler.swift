import Foundation
import FSRS
import SwiftData

final class TrainingScheduler {
    private let fsrs = FSRS(parameters: FSRSParameters())

    /// Selects the words to be displayed today:
    /// - new (state == .new)
    /// - words whose repetition period has come (due <= now)
    /// - limits the number of new
    func wordsForToday(from all: [WordProgress], newLimit: Int = 20) -> [WordProgress] {
        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        // All words that were ever designated as “new” today
        let assignedToday = all.filter { progress in
            if let assigned = progress.assignedDate {
                return calendar.isDate(assigned, inSameDayAs: today)
            }
            return false
        }

        // How many words have been entered today (doesn't matter if new/learning/review)
        let assignedTodayCount = assignedToday.count

        // New words specifically from today's set,
        // which are still in the .new state (they need to be displayed)
        var todaysNewWords = assignedToday.filter { $0.state == .new }

        // If the limit has not yet been selected, you can add more new ones.
        if assignedTodayCount < newLimit {
            let remainingSlots = newLimit - assignedTodayCount

            // Candidates: words .new that were not assigned today
            let candidateNewWords = all.filter { progress in
                guard progress.state == .new else { return false }

                if let assigned = progress.assignedDate {
                    // already scheduled, but on a different day — can be reused as “postponed”
                    return !calendar.isDate(assigned, inSameDayAs: today)
                } else {
                    // never appointed — new candidate
                    return true
                }
            }

            let newlyAssigned = Array(candidateNewWords.prefix(remainingSlots))

            // Mark them as assigned today
            newlyAssigned.forEach { progress in
                progress.assignedDate = today
            }

            // Adding to today's new additions
            todaysNewWords.append(contentsOf: newlyAssigned)
        }

        // Repetitions according to schedule FSRS
        let dueWords = all.filter {
            $0.state != .new && $0.due <= now
        }

        return todaysNewWords + dueWords
    }

    /// FSRS-correct calculation of the next state
    func nextReview(for progress: WordProgress, rating: Rating) -> WordProgress {
        let now = Date()

        // 1) lastReview should be stored in the WordProgress model
        // If it doesn't exist, we create it from the past due (fallback).
        let lastReview = progress.lastReview ?? (progress.state == .new ? nil : progress.due)

        let card = Card(
            due: progress.due,
            stability: progress.stability,
            difficulty: progress.difficulty,
            elapsedDays: Double(progress.elapsedDays),
            scheduledDays: Double(progress.scheduledDays),
            reps: progress.correctAnswers,
            lapses: progress.lapses,
            state: progress.state,
            lastReview: lastReview
        )

        do {
            let result = try fsrs.next(card: card, now: now, grade: rating)
            let next = result.card

            // Updating WordProgress correctly
            progress.stability = next.stability
            progress.difficulty = next.difficulty
            progress.elapsedDays = Int(next.elapsedDays)
            progress.scheduledDays = Int(next.scheduledDays)
            progress.due = next.due
            progress.state = next.state
            progress.lastReview = next.lastReview
            progress.lapses = next.lapses
            progress.correctAnswers = next.reps
            progress.learned = (next.state == .review)

        } catch {
            print("FSRS error:", error)
        }

        return progress
    }
}
