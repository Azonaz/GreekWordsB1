import SwiftUI

struct InfoView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        ZStack {
            Color.gray.opacity(0.05).ignoresSafeArea()
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Texts.information)
                    .font(sizeClass == .regular ? .largeTitle : .title2)
                    .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    InfoView()
}
