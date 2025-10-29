import SwiftUI

struct SettingsView: View {
    @State private var currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.05)
                .ignoresSafeArea()
            
            List {
                Button {
                    openAppSettings()
                } label: {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.primary)
                        
                        Text(Texts.language)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(displayName(for: currentLanguage))
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .navigationTitle(Texts.settings)
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
