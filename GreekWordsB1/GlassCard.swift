import SwiftUI

struct GlassCard: ViewModifier {
    var height: CGFloat
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        return content
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .font(.title)
            .foregroundStyle(.primary)
            .background(.ultraThinMaterial, in: shape)
            .contentShape(shape)
            .overlay(
                shape.stroke(.white.opacity(0.25), lineWidth: 1)
                    .allowsHitTesting(false)
            )
            .overlay(
                shape.fill(
                    LinearGradient(
                        colors: [.white.opacity(0.25), .clear],
                        startPoint: .top, endPoint: .center
                    )
                )
                .blendMode(.plusLighter)
                .opacity(0.7)
                .allowsHitTesting(false)
            )
            .shadow(radius: 3)
    }
}

extension View {
    func glassCard(height: CGFloat, cornerRadius: CGFloat) -> some View {
        modifier(GlassCard(height: height, cornerRadius: cornerRadius))
    }
}
