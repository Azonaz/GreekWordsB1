import Foundation

enum AppLanguage {
    static var code: String {
        Bundle.main.preferredLocalizations.first
            ?? Bundle.main.developmentLocalization
            ?? Locale.current.language.languageCode?.identifier
            ?? "en"
    }

    static var usesEnglishContent: Bool {
        code.hasPrefix("en")
    }
}
