import SwiftUI
import StoreKit

struct TrainingPaywallView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var trainingAccess: TrainingAccessManager
    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var purchasing = false
    @State private var errorMessage: String?

    private var buttonHeight: CGFloat {
        sizeClass == .regular ? 60 : 55
    }

    private var cornerRadius: CGFloat {
        sizeClass == .regular ? 30 : 25
    }

    private var horizontalPadding: CGFloat {
        sizeClass == .regular ? 100 : 60
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.05)
                .ignoresSafeArea()

            VStack(spacing: 24) {

                Text("Training Access Expired")
                    .font(sizeClass == .regular ? .largeTitle : .title)
                    .fontWeight(.semibold)
                    .padding(.top, sizeClass == .regular ? 40 : 20)

                Text("Unlock unlimited access to Training with a one-time purchase.")
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Purchase Button
                if let product = purchaseManager.products.first(where: { $0.id == "training_unlock" }) {

                    Button {
                        Task {
                            purchasing = true
                            let success = await purchaseManager.purchase(product)
                            purchasing = false

                            if success {
                                trainingAccess.setUnlocked()
                            } else {
                                errorMessage = "Purchase failed. Please try again."
                            }
                        }
                    } label: {
                        Text(purchasing ? "Processing…" : "Unlock for \(product.displayPrice)")
                            .frame(maxWidth: .infinity)
                            .frame(height: buttonHeight)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(cornerRadius)
                    }
                    .padding(.horizontal, horizontalPadding)
                    .disabled(purchasing)

                } else {
                    ProgressView("Loading price…")
                        .padding(.top, 8)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 4)
                }

                Spacer()
            }
        }
        .background(
            Image(.pillar)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.2)
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Training")
                    .font(sizeClass == .regular ? .largeTitle : .title2)
                    .foregroundColor(.primary)
            }
        }
    }
}
