import Foundation
import FSRS

final class StatsService {
    static func wordsDueTomorrow(_ all: [WordProgress]) -> Int {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        return all.filter { $0.state != .new && $0.due.isSameDay(as: tomorrow) }.count
    }

    static func stabilityDistribution(_ all: [WordProgress]) -> [Double] {
        all.map { $0.stability }
    }

    static func strongestWords(_ all: [WordProgress], limit: Int = 20) -> [WordProgress] {
        all.sorted { $0.stability > $1.stability }.prefix(limit).map { $0 }
    }
}

extension Date {
    func isSameDay(as other: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, inSameDayAs: other)
    }
}
