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
