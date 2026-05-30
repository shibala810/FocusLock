//
//  HeartLock.swift — pink heart-shaped lock
//

import SwiftUI

struct HeartLock: View {
    var size: CGFloat = 64
    var color: Color = .pink

    var body: some View {
        let w = size, h = size * 80 / 64
        ZStack {
            // shackle: M20 34 V24 a12 12 0 0 1 24 0 V34
            Path { p in
                let s = w / 64
                p.move(to: CGPoint(x: 20 * s, y: 34 * s))
                p.addLine(to: CGPoint(x: 20 * s, y: 24 * s))
                p.addArc(center: CGPoint(x: 32 * s, y: 24 * s),
                         radius: 12 * s,
                         startAngle: .degrees(180),
                         endAngle: .degrees(0),
                         clockwise: false)
                p.addLine(to: CGPoint(x: 44 * s, y: 34 * s))
            }
            .stroke(color, style: StrokeStyle(lineWidth: w * 7 / 64,
                                              lineCap: .round))

            // body
            RoundedRectangle(cornerRadius: w * 13 / 64, style: .continuous)
                .fill(color)
                .frame(width: w * 44 / 64, height: h * 40 / 80)
                .offset(y: h * (32 + 20 - 40) / 80)

            // inner heart
            HeartShape()
                .fill(Color.white.opacity(0.92))
                .frame(width: w * 20 / 64, height: h * 16 / 80)
                .offset(y: h * (45 - 40) / 80)
        }
        .frame(width: w, height: h)
    }
}

private struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        // 32 60 c-6-4.6-10-7.6-10-12 a4.6 4.6 0 0 1 8.4-2.6 l1.6 2 1.6-2
        // A4.6 4.6 0 0 1 42 48 c0 4.4-4 7.4-10 12Z
        // scale to rect
        let sx = w / 20, sy = h / 16
        p.move(to: CGPoint(x: 10 * sx, y: 16 * sy))
        p.addCurve(to: CGPoint(x: 0,      y: 4 * sy),
                   control1: CGPoint(x: 4 * sx,  y: 11.4 * sy),
                   control2: CGPoint(x: 0,       y: 8.4  * sy))
        p.addArc(center: CGPoint(x: 4.6 * sx, y: 4 * sy),
                 radius: 4.6 * min(sx, sy),
                 startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        p.addLine(to: CGPoint(x: 10 * sx, y: 6 * sy))
        p.addArc(center: CGPoint(x: 15.4 * sx, y: 4 * sy),
                 radius: 4.6 * min(sx, sy),
                 startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        p.addCurve(to: CGPoint(x: 10 * sx, y: 16 * sy),
                   control1: CGPoint(x: 20 * sx, y: 8.4  * sy),
                   control2: CGPoint(x: 16 * sx, y: 11.4 * sy))
        p.closeSubpath()
        return p
    }
}
