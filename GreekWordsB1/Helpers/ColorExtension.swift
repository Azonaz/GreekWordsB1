import SwiftUI

extension Color {
    static var glassBackground: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(white: 1.0, alpha: 0.08)  // ночь: тёмное стекло
                : UIColor(white: 1.0, alpha: 0.95)  // день: белое стекло
        })
    }
}
