//
//  Volleyball.swift — pink/cream/dark kawaii volleyball
//

import SwiftUI

struct Volleyball: View {
    var size: CGFloat = 120
    var spin: Bool = false
    @Environment(\.fl) private var fl
    @State private var angle: Double = 0

    var body: some View {
        ZStack {
            // base circle with cream gradient
            Circle()
                .fill(RadialGradient(
                    colors: [fl.ballCream, Color(hex: 0xF4E0CF)],
                    center: UnitPoint(x: 0.38, y: 0.32),
                    startRadius: 0,
                    endRadius: size * 0.46))
                .overlay(Circle().stroke(fl.ballDark, lineWidth: size * 0.024))

            // panels + seams clipped to circle
            ZStack {
                Path { p in
                    let s = size
                    // pink panel (left side curve)
                    p.move(to: CGPoint(x: 0.50 * s, y: 0.04 * s))
                    p.addCurve(to: CGPoint(x: 0.38 * s, y: 0.96 * s),
                               control1: CGPoint(x: 0.30 * s, y: 0.22 * s),
                               control2: CGPoint(x: 0.26 * s, y: 0.50 * s))
                    p.addLine(to: CGPoint(x: 0.04 * s, y: 0.96 * s))
                    p.addLine(to: CGPoint(x: 0.04 * s, y: 0.04 * s))
                    p.closeSubpath()
                }
                .fill(fl.ballPink.opacity(0.95))

                Path { p in
                    let s = size
                    // dark panel (lower right)
                    p.move(to: CGPoint(x: 0.96 * s, y: 0.28 * s))
                    p.addCurve(to: CGPoint(x: 0.60 * s, y: 0.96 * s),
                               control1: CGPoint(x: 0.66 * s, y: 0.30 * s),
                               control2: CGPoint(x: 0.44 * s, y: 0.44 * s))
                    p.addLine(to: CGPoint(x: 0.96 * s, y: 0.96 * s))
                    p.closeSubpath()
                }
                .fill(fl.ballDark.opacity(0.9))

                // seam lines
                Path { p in
                    let s = size
                    p.move(to: CGPoint(x: 0.50 * s, y: 0.03 * s))
                    p.addCurve(to: CGPoint(x: 0.42 * s, y: 0.97 * s),
                               control1: CGPoint(x: 0.36 * s, y: 0.24 * s),
                               control2: CGPoint(x: 0.33 * s, y: 0.52 * s))

                    p.move(to: CGPoint(x: 0.03 * s, y: 0.40 * s))
                    p.addCurve(to: CGPoint(x: 0.78 * s, y: 0.98 * s),
                               control1: CGPoint(x: 0.26 * s, y: 0.36 * s),
                               control2: CGPoint(x: 0.64 * s, y: 0.74 * s))

                    p.move(to: CGPoint(x: 0.97 * s, y: 0.30 * s))
                    p.addCurve(to: CGPoint(x: 0.35 * s, y: 0.99 * s),
                               control1: CGPoint(x: 0.48 * s, y: 0.44 * s),
                               control2: CGPoint(x: 0.36 * s, y: 0.84 * s))
                }
                .stroke(fl.ballDark, style: StrokeStyle(lineWidth: size * 0.022,
                                                        lineCap: .round))
            }
            .clipShape(Circle().inset(by: size * 0.04))

            // shine highlight
            Ellipse()
                .fill(Color.white.opacity(0.32))
                .frame(width: size * 0.26, height: size * 0.18)
                .offset(x: -size * 0.14, y: -size * 0.20)
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(angle))
        .onAppear { startSpin() }
        .onChange(of: spin) { _, _ in startSpin() }
    }

    private func startSpin() {
        guard spin else { angle = 0; return }
        withAnimation(.linear(duration: 22).repeatForever(autoreverses: false)) {
            angle = 360
        }
    }
}

#Preview {
    HStack {
        Volleyball(size: 120, spin: false)
        Volleyball(size: 60, spin: true)
    }
    .padding()
    .background(Color(hex: 0xFBE3E9))
    .flTheme()
    .environment(AppState.preview)
}
