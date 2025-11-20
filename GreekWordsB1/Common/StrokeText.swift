import SwiftUI

struct StrokeText: UIViewRepresentable {
    let text: String
    let fontSize: CGFloat
    let weight: UIFont.Weight
    let fillColor: UIColor
    let strokeColor: UIColor
    let strokeWidth: CGFloat
    let kerning: CGFloat

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .right
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        let font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        let attr = NSMutableAttributedString(string: text)

        attr.addAttributes([
            .font: font,
            .foregroundColor: fillColor,
            .strokeColor: strokeColor,
            .strokeWidth: -strokeWidth,
            .kern: kerning
        ], range: NSRange(location: 0, length: attr.length))

        uiView.attributedText = attr
    }
}
