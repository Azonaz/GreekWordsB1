import SwiftUI

let baseURL = "https://azonaz.github.io/words-gr-b1.json"

enum Texts {
    static let quiz: LocalizedStringKey = "quiz"
    static let soon: LocalizedStringKey = "soon"
    static let categories: LocalizedStringKey = "categories"
    static let settings: LocalizedStringKey = "settings"
    static let statistics: LocalizedStringKey = "statistics"
    static let language: LocalizedStringKey = "language"
    static let restart: LocalizedStringKey = "restart"
    static let back: LocalizedStringKey = "back"
    static let result: LocalizedStringKey = "result"
    static let information: LocalizedStringKey = "information"

    static var allWords: String {
        NSLocalizedString("allWords", comment: "")
    }

    static var quizzesCompleted: String {
        NSLocalizedString("quizzesCompleted", comment: "")
    }

    static var wordsSeen: String {
        NSLocalizedString("wordsSeen", comment: "")
    }

    static var averagePercentage: String {
        NSLocalizedString("averagePercentage", comment: "")
    }

    static var blurOn: String {
        NSLocalizedString("blurOn", comment: "")
    }

    static var blurOff: String {
        NSLocalizedString("blurOff", comment: "")
    }
}
