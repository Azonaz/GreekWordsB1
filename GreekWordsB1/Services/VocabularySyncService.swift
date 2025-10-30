import Foundation
import SwiftData

final class VocabularySyncService {
    private let context: ModelContext
    private let remoteURL: URL
    private(set) var dictionaryUrl = "https://azonaz.github.io/words-gr-b1.json"

    init(context: ModelContext, remoteURL: URL) {
        self.context = context
        self.remoteURL = remoteURL
    }

    /// Basic sync logic
    func syncVocabulary() async throws {
        let (data, _) = try await URLSession.shared.data(from: remoteURL)
        let vocabularyFile = try JSONDecoder().decode(VocabularyFile.self, from: data)

        for group in vocabularyFile.vocabulary.groups {
            try await syncGroup(group)
        }

        try context.save()
    }
}

private extension VocabularySyncService {
    func syncGroup(_ group: WordGroup) async throws {
        // Check group version
        let existingMeta = try context.fetch(
            FetchDescriptor<GroupMeta>(predicate: #Predicate { $0.id == group.id })
        ).first

        if let existingMeta = existingMeta, existingMeta.version >= group.version {
            // If the version is the same or greater, we don't need to update
            return
        }

        // Replace meta
        let meta = existingMeta ?? GroupMeta(
            id: group.id,
            version: group.version,
            nameEn: group.name.en,
            nameRu: group.name.ru
        )
        meta.version = group.version
        meta.nameEn = group.name.en
        meta.nameRu = group.name.ru
        context.insert(meta)

        // Delete old words
        let oldWords = try context.fetch(
            FetchDescriptor<Word>(predicate: #Predicate { $0.groupID == group.id })
        )
        for oldWord in oldWords { context.delete(oldWord) }

        // Add new words
        for word in group.words {
            let newWord = Word(
                localID: word.id,
                groupID: group.id,
                gr: word.gr,
                en: word.en,
                ru: word.ru
            )
            context.insert(newWord)
        }
    }
}
