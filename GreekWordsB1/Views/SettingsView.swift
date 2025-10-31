import SwiftUI

struct SettingsView: View {
    @State private var currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
    @Environment(\.horizontalSizeClass) var sizeClass
    @AppStorage("isBlurEnabled") private var isBlurEnabled = true

    var body: some View {
        ZStack {
            Color.gray.opacity(0.05)
                .ignoresSafeArea()

            List {
                Button {
                    openAppSettings()
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "globe")
                            .font(.body)
                            .imageScale(.large)
                            .foregroundColor(.primary)

                        Text(Texts.language)
                            .font(.body)
                            .foregroundColor(.primary)

                        Spacer()

                        Text(displayName(for: currentLanguage))
                            .font(.body)
                            .foregroundColor(.secondary)

                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 8)
                }

                GlassToggle(
                    isOn: $isBlurEnabled,
                    label: isBlurEnabled ? Texts.blurOn : Texts.blurOff
                )
            }
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Texts.settings)
                    .font(sizeClass == .regular ? .largeTitle : .title2)
                    .foregroundColor(.primary)
            }
        }
        .scrollContentBackground(.hidden)
        .onAppear {
            updateLanguage()
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    private func updateLanguage() {
        currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
    }

    private func displayName(for code: String) -> String {
        switch code {
        case "ru": return "Русский"
        case "en": return "English"
        default: return code.uppercased()
        }
    }
}

#Preview {
    SettingsView()
}
