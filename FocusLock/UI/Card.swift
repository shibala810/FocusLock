//
//  Card.swift — soft-rounded surface card
//

import SwiftUI

struct FLCard<Content: View>: View {
    var cornerRadius: CGFloat = 28
    var smallShadow: Bool = false
    var background: Color? = nil
    @ViewBuilder var content: () -> Content
    @Environment(\.fl) private var fl

    var body: some View {
        let bg = background ?? fl.surface
        content()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(bg)
            )
            .modifier(smallShadow ? AnyShadow(.small(fl)) : AnyShadow(.regular(fl)))
    }
}

struct AnyShadow: ViewModifier {
    enum Kind { case regular(FLPalette), small(FLPalette), pop(FLPalette) }
    let kind: Kind
    init(_ k: Kind) { kind = k }
    func body(content: Content) -> some View {
        switch kind {
        case .regular(let fl):
            content.shadow(color: fl.cardShadow, radius: 14, x: 0, y: 10)
        case .small(let fl):
            content.shadow(color: fl.cardShadowSmall, radius: 7, x: 0, y: 4)
        case .pop(let fl):
            content.shadow(color: fl.pop, radius: 25, x: 0, y: 18)
        }
    }
}
