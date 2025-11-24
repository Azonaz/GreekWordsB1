import SwiftUI

struct SettingsView: View {
    @State private var currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
    @Environment(\.horizontalSizeClass) var sizeClass
    @AppStorage("isBlurEnabled") private var isBlurEnabled = false
    @AppStorage("dailyNewWordsLimit") private var dailyNewWordsLimit: Int = 20

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

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 14) {
                        Image(systemName: "character.book.closed")
                            .font(.body)
                            .imageScale(.large)
                            .foregroundColor(.primary)

                        Text(Texts.newWordsNumber)
                            .font(.body)
                            .foregroundColor(.primary)
                    }

                    GlassSegmentedControl(
                        items: [10, 20, 30],
                        label: { "\($0)" },
                        selection: $dailyNewWordsLimit
                    )
                }
                .padding(.vertical, 8)
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
