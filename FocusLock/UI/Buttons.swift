//
//  Buttons.swift — fl-cta and fl-pill button styles
//

import SwiftUI

/// Big squishy gradient CTA — pink by default; pass `gradient` to override.
struct FLCTAStyle: ButtonStyle {
    var gradient: LinearGradient? = nil
    var shadowColor: Color? = nil
    @Environment(\.fl) private var fl

    func makeBody(configuration: Configuration) -> some View {
        let g = gradient ?? LinearGradient(
            colors: [fl.primary, fl.primaryDeep],
            startPoint: .top, endPoint: .bottom)
        let sh = shadowColor ?? fl.primaryDeep
        configuration.label
            .font(.system(size: 17, weight: .heavy))
            .foregroundStyle(fl.onPrimary)
            .padding(.vertical, 17)
            .padding(.horizontal, 22)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous).fill(g)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.4), lineWidth: 2)
                    .blendMode(.plusLighter)
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .frame(maxHeight: 4, alignment: .top)
            )
            .shadow(color: sh.opacity(0.7), radius: 11, y: configuration.isPressed ? 4 : 10)
            .offset(y: configuration.isPressed ? 2 : 0)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.spring(response: 0.18, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// Pill button — flat capsule, scales on press.
struct FLPillStyle: ButtonStyle {
    var background: Color
    var foreground: Color
    var padding: EdgeInsets = EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14.5, weight: .heavy))
            .foregroundStyle(foreground)
            .padding(padding)
            .background(Capsule().fill(background))
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.18, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
