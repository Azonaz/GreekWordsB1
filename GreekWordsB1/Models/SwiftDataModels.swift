import SwiftData

@Model
final class Word {
    @Attribute(.unique) var compositeID: String
    var localID: Int
    var groupID: Int
    var gr: String
    var en: String
    var ru: String
    
    init(localID: Int, groupID: Int, gr: String, en: String, ru: String) {
        self.localID = localID
        self.groupID = groupID
        self.gr = gr
        self.en = en
        self.ru = ru
        self.compositeID = "\(groupID)_\(localID)"
    }
}

@Model
final class GroupMeta {
    @Attribute(.unique) var id: Int
    var version: Int
    var nameEn: String
    var nameRu: String
    
    init(id: Int, version: Int, nameEn: String, nameRu: String) {
        self.id = id
        self.version = version
        self.nameEn = nameEn
        self.nameRu = nameRu
    }
}

@Model
final class WordProgress {
    @Attribute(.unique) var compositeID: String
    var learned: Bool
    var correctAnswers: Int

    init(compositeID: String, learned: Bool = false, correctAnswers: Int = 0) {
        self.compositeID = compositeID
        self.learned = learned
        self.correctAnswers = correctAnswers
    }
}
