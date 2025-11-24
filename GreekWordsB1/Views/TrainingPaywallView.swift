import SwiftUI

struct TrainingPaywallView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.05)
                    .ignoresSafeArea()
                VStack(spacing: 24) {
                    Text("The free week is over.")
                        .font(.title2)
                        .multilineTextAlignment(.center)

                    Text("The training will be available after purchase. The payment screen will appear here shortly.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button("Back") {

                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .background(
            Image(.pillar)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.2)
            )
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Texts.training)
                    .font(sizeClass == .regular ? .largeTitle : .title2)
                    .foregroundColor(.primary)
            }
        }
    }
}
