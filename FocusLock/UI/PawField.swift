//
//  PawField.swift — decorative scattered paws + sparkles
//

import SwiftUI

struct PawField: View {
    @Environment(\.fl) private var fl
    @State private var twinkle = false

    private struct PawSpec { let x: Double; let y: Double; let s: CGFloat; let r: Double; let o: Double }
    private let items: [PawSpec] = [
        .init(x: 0.08, y: 0.10, s: 26, r: -18, o: 0.5),
        .init(x: 0.82, y: 0.07, s: 20, r:  14, o: 0.4),
        .init(x: 0.70, y: 0.22, s: 15, r:  -8, o: 0.35),
        .init(x: 0.16, y: 0.30, s: 16, r:  20, o: 0.3),
        .init(x: 0.90, y: 0.40, s: 22, r: -22, o: 0.32),
        .init(x: 0.05, y: 0.58, s: 18, r:  10, o: 0.3),
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(items.indices, id: \.self) { i in
                    let it = items[i]
                    Paw(size: it.s, color: fl.paw)
                        .opacity(it.o)
                        .rotationEffect(.degrees(it.r))
                        .position(x: it.x * geo.size.width, y: it.y * geo.size.height)
                }
                Sparkle(size: 14, color: fl.blonde).opacity(twinkle ? 1 : 0.3)
                    .position(x: 0.26 * geo.size.width, y: 0.16 * geo.size.height)
                Sparkle(size: 11, color: fl.primary).opacity(twinkle ? 1 : 0.3)
                    .position(x: 0.60 * geo.size.width, y: 0.12 * geo.size.height)
                Sparkle(size: 12, color: fl.blonde).opacity(twinkle ? 0.6 : 1)
                    .position(x: 0.88 * geo.size.width, y: 0.60 * geo.size.height)
            }
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                    twinkle.toggle()
                }
            }
        }
        .allowsHitTesting(false)
    }
}
