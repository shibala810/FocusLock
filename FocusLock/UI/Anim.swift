//
//  Anim.swift — reusable lightweight animation modifiers
//

import SwiftUI

struct BreatheMod: ViewModifier {
    @State private var on = false
    var duration: Double = 4
    var amplitude: CGFloat = 0.045
    func body(content: Content) -> some View {
        content
            .scaleEffect(on ? (1 + amplitude) : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    on.toggle()
                }
            }
    }
}

struct FloatMod: ViewModifier {
    @State private var on = false
    var duration: Double = 5
    func body(content: Content) -> some View {
        content
            .offset(y: on ? -7 : 0)
            .rotationEffect(.degrees(on ? 2 : -2))
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    on.toggle()
                }
            }
    }
}

struct WiggleMod: ViewModifier {
    @State private var on = false
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(on ? 3 : -3))
            .onAppear {
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    on.toggle()
                }
            }
    }
}

extension View {
    func flBreathe(duration: Double = 4, amplitude: CGFloat = 0.045) -> some View {
        modifier(BreatheMod(duration: duration, amplitude: amplitude))
    }
    func flFloat(duration: Double = 5) -> some View {
        modifier(FloatMod(duration: duration))
    }
    func flWiggle() -> some View {
        modifier(WiggleMod())
    }
}
