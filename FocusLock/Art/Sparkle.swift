//
//  Sparkle.swift — 4-point sparkle
//

import SwiftUI

struct SparkleShape: Shape {
    func path(in rect: CGRect) -> Path {
        // M12 0 C12.8 7 13.4 9.2 24 12 C13.4 14.8 12.8 17 12 24
        // C11.2 17 10.6 14.8 0 12 C10.6 9.2 11.2 7 12 0Z
        let s = min(rect.width, rect.height) / 24
        var p = Path()
        p.move(to: CGPoint(x: 12 * s, y: 0))
        p.addCurve(to: CGPoint(x: 24 * s, y: 12 * s),
                   control1: CGPoint(x: 12.8 * s, y: 7  * s),
                   control2: CGPoint(x: 13.4 * s, y: 9.2 * s))
        p.addCurve(to: CGPoint(x: 12 * s, y: 24 * s),
                   control1: CGPoint(x: 13.4 * s, y: 14.8 * s),
                   control2: CGPoint(x: 12.8 * s, y: 17 * s))
        p.addCurve(to: CGPoint(x: 0,       y: 12 * s),
                   control1: CGPoint(x: 11.2 * s, y: 17 * s),
                   control2: CGPoint(x: 10.6 * s, y: 14.8 * s))
        p.addCurve(to: CGPoint(x: 12 * s, y: 0),
                   control1: CGPoint(x: 10.6 * s, y: 9.2 * s),
                   control2: CGPoint(x: 11.2 * s, y: 7  * s))
        p.closeSubpath()
        return p
    }
}

struct Sparkle: View {
    var size: CGFloat = 16
    var color: Color = .white
    var body: some View {
        SparkleShape().fill(color).frame(width: size, height: size)
    }
}
