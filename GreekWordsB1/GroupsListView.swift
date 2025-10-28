import SwiftUI
import SwiftData

struct GroupsListView: View {
    @Query(sort: \GroupMeta.nameEn) private var groups: [GroupMeta]
    
    var body: some View {
        List(groups) { group in
            Text(group.nameEn)
        }
        .navigationTitle("Categories")
    }
}

#Preview {
    let schema = Schema([GroupMeta.self, Word.self, WordProgress.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let ctx = ModelContext(container)
    ctx.insert(GroupMeta(id: 1, version: 1, nameEn: "Meeting", nameRu: "Встреча"))
    ctx.insert(GroupMeta(id: 2, version: 1, nameEn: "Family",  nameRu: "Семья"))
    ctx.insert(GroupMeta(id: 3, version: 2, nameEn: "Travel",  nameRu: "Путешествия"))

    return NavigationStack {
        GroupsListView()
    }
    .modelContainer(container)
}
