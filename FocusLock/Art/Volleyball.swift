//
//  Volleyball.swift — kawaii volleyball, Mikasa-style 3-seam junction
//

import SwiftUI

struct Volleyball: View {
    var size: CGFloat = 120
    var spin: Bool = false
    @Environment(\.fl) private var fl
    @State private var angle: Double = 0

    var body: some View {
        // Geometry: three seams converge at a single off-center "junction"
        // point (upper-right area). Between them sit three differently-coloured
        // panels — this is the visual signature of a volleyball viewed from
        // one face. We trace each panel as a closed curve through the
        // junction + two arc points on the rim, so panels meet exactly along
        // the seams with no gaps.
        let s = size
        let J = CGPoint(x: 0.66 * s, y: 0.30 * s)         // junction
        // Seam endpoints on the circle rim (angles measured clockwise from 12 o'clock).
        let topEnd    = pointOnRim(angleDeg: -10,  size: s)
        let leftEnd   = pointOnRim(angleDeg: -130, size: s)
        let bottomEnd = pointOnRim(angleDeg:  130, size: s)
        // Bezier control points pulled toward the centre to give each seam an arched look.
        let cTop      = CGPoint(x: 0.78 * s, y: 0.10 * s)
        let cLeft     = CGPoint(x: 0.22 * s, y: 0.40 * s)
        let cBottom   = CGPoint(x: 0.74 * s, y: 0.80 * s)

        ZStack {
            // Base sphere — cream with a soft radial gradient and rim stroke.
            Circle()
                .fill(RadialGradient(
                    colors: [fl.ballCream, Color(hex: 0xE9D2BB)],
                    center: UnitPoint(x: 0.36, y: 0.30),
                    startRadius: 0,
                    endRadius: s * 0.55))
                .overlay(Circle().stroke(fl.ballDark, lineWidth: s * 0.028))

            ZStack {
                // Top panel — pink. Wedge between the topEnd seam and the leftEnd seam,
                // closed along the upper-left arc of the ball.
                Path { p in
                    p.move(to: J)
                    p.addQuadCurve(to: topEnd,   control: cTop)
                    p.addArc(center: CGPoint(x: 0.5 * s, y: 0.5 * s),
                             radius: 0.48 * s,
                             startAngle: rim(-10),
                             endAngle:   rim(-130),
                             clockwise: true)
                    p.addQuadCurve(to: J, control: cLeft)
                    p.closeSubpath()
                }
                .fill(fl.ballPink.opacity(0.95))

                // Bottom panel — dark. Wedge between the leftEnd seam and the bottomEnd seam,
                // closed along the lower arc.
                Path { p in
                    p.move(to: J)
                    p.addQuadCurve(to: leftEnd,   control: cLeft)
                    p.addArc(center: CGPoint(x: 0.5 * s, y: 0.5 * s),
                             radius: 0.48 * s,
                             startAngle: rim(-130),
                             endAngle:   rim(130),
                             clockwise: true)
                    p.addQuadCurve(to: J, control: cBottom)
                    p.closeSubpath()
                }
                .fill(fl.ballDark.opacity(0.92))

                // Right panel stays cream (no fill needed — the base shows through),
                // bounded by the topEnd and bottomEnd seams + the right rim arc.

                // The three seams, drawn over the panels so they read clearly.
                Path { p in
                    p.move(to: J); p.addQuadCurve(to: topEnd,    control: cTop)
                    p.move(to: J); p.addQuadCurve(to: leftEnd,   control: cLeft)
                    p.move(to: J); p.addQuadCurve(to: bottomEnd, control: cBottom)
                }
                .stroke(fl.ballDark,
                        style: StrokeStyle(lineWidth: s * 0.028, lineCap: .round))

                // Stitching ticks along each seam — short perpendicular dashes
                // that give the seam a sewn look without going overboard.
                stitching(from: J, to: topEnd,    control: cTop,    size: s)
                stitching(from: J, to: leftEnd,   control: cLeft,   size: s)
                stitching(from: J, to: bottomEnd, control: cBottom, size: s)
            }
            .clipShape(Circle().inset(by: s * 0.026))

            // Specular highlight up-top-left, sells the spherical lighting.
            Ellipse()
                .fill(Color.white.opacity(0.42))
                .frame(width: s * 0.28, height: s * 0.18)
                .rotationEffect(.degrees(-22))
                .offset(x: -s * 0.16, y: -s * 0.22)
                .blur(radius: s * 0.008)
        }
        .frame(width: s, height: s)
        .rotationEffect(.degrees(angle))
        .onAppear { startSpin() }
        .onChange(of: spin) { _, _ in startSpin() }
    }

    // MARK: - Helpers

    private func pointOnRim(angleDeg: Double, size s: CGFloat) -> CGPoint {
        // 0° = 12 o'clock, growing clockwise.
        let r = 0.48 * s
        let c = CGPoint(x: 0.5 * s, y: 0.5 * s)
        let rad = angleDeg * .pi / 180
        let dx = CGFloat(sin(rad))
        let dy = CGFloat(cos(rad))
        return CGPoint(x: c.x + r * dx, y: c.y - r * dy)
    }

    private func rim(_ degClockwiseFromTop: Double) -> Angle {
        // Convert "0° = top, growing clockwise" into SwiftUI's "0° = +x axis,
        // growing counter-clockwise" so addArc points the right way.
        Angle.degrees(degClockwiseFromTop - 90)
    }

    @ViewBuilder
    private func stitching(from a: CGPoint, to b: CGPoint, control c: CGPoint, size s: CGFloat) -> some View {
        // Approximate the seam with a few evenly-spaced ticks. Each tick is a
        // short line perpendicular to the local tangent.
        let count = 6
        let len   = s * 0.022
        Path { p in
            for i in 1...count {
                let t = CGFloat(i) / CGFloat(count + 1)
                let pt = quadBezierPoint(a: a, c: c, b: b, t: t)
                let tan = quadBezierTangent(a: a, c: c, b: b, t: t)
                let norm = perpendicular(of: tan)
                p.move(to: CGPoint(x: pt.x - norm.x * len, y: pt.y - norm.y * len))
                p.addLine(to: CGPoint(x: pt.x + norm.x * len, y: pt.y + norm.y * len))
            }
        }
        .stroke(fl.ballDark.opacity(0.55),
                style: StrokeStyle(lineWidth: s * 0.012, lineCap: .round))
    }

    private func quadBezierPoint(a: CGPoint, c: CGPoint, b: CGPoint, t: CGFloat) -> CGPoint {
        let u = 1 - t
        return CGPoint(x: u*u*a.x + 2*u*t*c.x + t*t*b.x,
                       y: u*u*a.y + 2*u*t*c.y + t*t*b.y)
    }

    private func quadBezierTangent(a: CGPoint, c: CGPoint, b: CGPoint, t: CGFloat) -> CGPoint {
        let u = 1 - t
        let x = 2*u*(c.x - a.x) + 2*t*(b.x - c.x)
        let y = 2*u*(c.y - a.y) + 2*t*(b.y - c.y)
        let mag = max(0.0001, sqrt(x*x + y*y))
        return CGPoint(x: x / mag, y: y / mag)
    }

    private func perpendicular(of v: CGPoint) -> CGPoint {
        // Rotate 90°.
        CGPoint(x: -v.y, y: v.x)
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
        Volleyball(size: 180, spin: false)
        Volleyball(size: 120, spin: true)
        Volleyball(size: 60,  spin: false)
    }
    .padding()
    .background(Color(hex: 0xFBE3E9))
    .flTheme()
    .environment(AppState.preview)
}
