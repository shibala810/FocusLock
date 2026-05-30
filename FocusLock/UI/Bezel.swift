//
//  Bezel.swift — full-screen container with theme-aware background
//

import SwiftUI

/// Base "screen" wrapper: full-bleed background + radial gradient.
/// (We don't draw an iPhone bezel — the real device's own chrome is the bezel.)
struct FLScreen<Content: View>: View {
    @Environment(\.fl) private var fl
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [fl.bgTop, fl.bg],
                center: UnitPoint(x: 0.5, y: -0.1),
                startRadius: 0,
                endRadius: 700
            )
            .ignoresSafeArea()

            content()
                .iPadContentWidth()
        }
    }
}
