//
//  LineIcon.swift — generic 24-unit stroke icons
//

import SwiftUI

struct LineIcon: View {
    enum Name: String {
        case chevron, back, close, plus, check, clock, bell, shield, flame, info, book, trash, breath, heart, lock, unlock, siren
    }

    let name: Name
    var size: CGFloat = 20
    var color: Color = .primary
    var strokeWidth: CGFloat = 2.2

    var body: some View {
        let sw = strokeWidth * size / 24
        let style = StrokeStyle(lineWidth: sw, lineCap: .round, lineJoin: .round)

        Canvas { ctx, _ in
            let scale = size / 24
            ctx.scaleBy(x: scale, y: scale)
            let stroke = GraphicsContext.Shading.color(color)
            switch name {
            case .chevron:
                var p = Path(); p.move(to: CGPoint(x: 9, y: 5))
                p.addLine(to: CGPoint(x: 16, y: 12)); p.addLine(to: CGPoint(x: 9, y: 19))
                ctx.stroke(p, with: stroke, style: style)
            case .back:
                var p = Path(); p.move(to: CGPoint(x: 15, y: 5))
                p.addLine(to: CGPoint(x: 8, y: 12)); p.addLine(to: CGPoint(x: 15, y: 19))
                ctx.stroke(p, with: stroke, style: style)
            case .close:
                var p = Path()
                p.move(to: CGPoint(x: 6, y: 6));  p.addLine(to: CGPoint(x: 18, y: 18))
                p.move(to: CGPoint(x: 18, y: 6)); p.addLine(to: CGPoint(x: 6, y: 18))
                ctx.stroke(p, with: stroke, style: style)
            case .plus:
                var p = Path()
                p.move(to: CGPoint(x: 12, y: 5)); p.addLine(to: CGPoint(x: 12, y: 19))
                p.move(to: CGPoint(x: 5, y: 12)); p.addLine(to: CGPoint(x: 19, y: 12))
                ctx.stroke(p, with: stroke, style: style)
            case .check:
                var p = Path(); p.move(to: CGPoint(x: 5, y: 13))
                p.addLine(to: CGPoint(x: 9, y: 17)); p.addLine(to: CGPoint(x: 19, y: 7))
                ctx.stroke(p, with: stroke, style: style)
            case .clock:
                ctx.stroke(Path(ellipseIn: CGRect(x: 4, y: 4, width: 16, height: 16)),
                           with: stroke, style: style)
                var p = Path(); p.move(to: CGPoint(x: 12, y: 8))
                p.addLine(to: CGPoint(x: 12, y: 12.5)); p.addLine(to: CGPoint(x: 15, y: 14.5))
                ctx.stroke(p, with: stroke, style: style)
            case .bell:
                var p = Path()
                p.move(to: CGPoint(x: 6, y: 9))
                p.addCurve(to: CGPoint(x: 18, y: 9),
                           control1: CGPoint(x: 6, y: 3), control2: CGPoint(x: 18, y: 3))
                p.addCurve(to: CGPoint(x: 20, y: 15),
                           control1: CGPoint(x: 18, y: 14), control2: CGPoint(x: 20, y: 15))
                p.addLine(to: CGPoint(x: 4, y: 15))
                p.addCurve(to: CGPoint(x: 6, y: 9),
                           control1: CGPoint(x: 4, y: 15), control2: CGPoint(x: 6, y: 14))
                ctx.stroke(p, with: stroke, style: style)
                var b = Path(); b.move(to: CGPoint(x: 10, y: 19))
                b.addCurve(to: CGPoint(x: 14, y: 19),
                           control1: CGPoint(x: 10, y: 20.5), control2: CGPoint(x: 14, y: 20.5))
                ctx.stroke(b, with: stroke, style: style)
            case .shield:
                var p = Path()
                p.move(to: CGPoint(x: 12, y: 3))
                p.addLine(to: CGPoint(x: 19, y: 6))
                p.addLine(to: CGPoint(x: 19, y: 11))
                p.addCurve(to: CGPoint(x: 12, y: 20),
                           control1: CGPoint(x: 19, y: 16), control2: CGPoint(x: 15.5, y: 19))
                p.addCurve(to: CGPoint(x: 5, y: 11),
                           control1: CGPoint(x: 8.5, y: 19), control2: CGPoint(x: 5, y: 16))
                p.addLine(to: CGPoint(x: 5, y: 6))
                p.closeSubpath()
                ctx.stroke(p, with: stroke, style: style)
            case .flame:
                var p = Path()
                p.move(to: CGPoint(x: 12, y: 3))
                p.addCurve(to: CGPoint(x: 9, y: 12),
                           control1: CGPoint(x: 13, y: 7), control2: CGPoint(x: 9, y: 8))
                p.addArc(center: CGPoint(x: 12, y: 12),
                         radius: 3, startAngle: .degrees(180),
                         endAngle: .degrees(0), clockwise: false)
                p.addCurve(to: CGPoint(x: 7, y: 14),
                           control1: CGPoint(x: 14, y: 10.5), control2: CGPoint(x: 9, y: 12.5))
                p.addCurve(to: CGPoint(x: 12, y: 21),
                           control1: CGPoint(x: 4, y: 18), control2: CGPoint(x: 8, y: 21))
                p.addCurve(to: CGPoint(x: 18, y: 14),
                           control1: CGPoint(x: 16, y: 21), control2: CGPoint(x: 20, y: 18))
                ctx.stroke(p, with: stroke, style: style)
            case .info:
                ctx.stroke(Path(ellipseIn: CGRect(x: 3.5, y: 3.5, width: 17, height: 17)),
                           with: stroke, style: style)
                var p = Path()
                p.move(to: CGPoint(x: 12, y: 11)); p.addLine(to: CGPoint(x: 12, y: 16))
                p.move(to: CGPoint(x: 12, y: 8));  p.addLine(to: CGPoint(x: 12.01, y: 8))
                ctx.stroke(p, with: stroke, style: style)
            case .book:
                var p = Path()
                p.move(to: CGPoint(x: 5, y: 4))
                p.addLine(to: CGPoint(x: 16, y: 4))
                p.addCurve(to: CGPoint(x: 19, y: 7),
                           control1: CGPoint(x: 18, y: 4), control2: CGPoint(x: 19, y: 5))
                p.addLine(to: CGPoint(x: 19, y: 20))
                p.addLine(to: CGPoint(x: 8, y: 20))
                p.addCurve(to: CGPoint(x: 5, y: 17),
                           control1: CGPoint(x: 6, y: 20), control2: CGPoint(x: 5, y: 19))
                p.closeSubpath()
                ctx.stroke(p, with: stroke, style: style)
            case .trash:
                var p = Path()
                p.move(to: CGPoint(x: 5, y: 7));   p.addLine(to: CGPoint(x: 19, y: 7))
                p.move(to: CGPoint(x: 9, y: 7));   p.addLine(to: CGPoint(x: 9, y: 5))
                p.addLine(to: CGPoint(x: 15, y: 5)); p.addLine(to: CGPoint(x: 15, y: 7))
                p.move(to: CGPoint(x: 7, y: 7));   p.addLine(to: CGPoint(x: 8, y: 20))
                p.addLine(to: CGPoint(x: 16, y: 20)); p.addLine(to: CGPoint(x: 17, y: 7))
                ctx.stroke(p, with: stroke, style: style)
            case .breath:
                ctx.stroke(Path(ellipseIn: CGRect(x: 9, y: 9, width: 6, height: 6)),
                           with: stroke, style: style)
                ctx.stroke(Path(ellipseIn: CGRect(x: 4, y: 4, width: 16, height: 16)),
                           with: GraphicsContext.Shading.color(color.opacity(0.5)), style: style)
            case .heart:
                var p = Path()
                p.move(to: CGPoint(x: 12, y: 20))
                p.addCurve(to: CGPoint(x: 5, y: 10),
                           control1: CGPoint(x: 7, y: 17), control2: CGPoint(x: 5, y: 14))
                p.addArc(center: CGPoint(x: 9, y: 8), radius: 4,
                         startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                p.addArc(center: CGPoint(x: 15, y: 8), radius: 4,
                         startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                p.addCurve(to: CGPoint(x: 12, y: 20),
                           control1: CGPoint(x: 19, y: 14), control2: CGPoint(x: 17, y: 17))
                ctx.stroke(p, with: stroke, style: style)
            case .lock:
                ctx.stroke(Path(roundedRect: CGRect(x: 5, y: 10, width: 14, height: 10), cornerRadius: 3),
                           with: stroke, style: style)
                var p = Path()
                p.move(to: CGPoint(x: 8, y: 10))
                p.addLine(to: CGPoint(x: 8, y: 7))
                p.addArc(center: CGPoint(x: 12, y: 7), radius: 4,
                         startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                p.addLine(to: CGPoint(x: 16, y: 10))
                ctx.stroke(p, with: stroke, style: style)
            case .unlock:
                ctx.stroke(Path(roundedRect: CGRect(x: 5, y: 10, width: 14, height: 10), cornerRadius: 3),
                           with: stroke, style: style)
                var p = Path()
                p.move(to: CGPoint(x: 8, y: 10))
                p.addLine(to: CGPoint(x: 8, y: 7))
                p.addArc(center: CGPoint(x: 11.75, y: 7), radius: 3.75,
                         startAngle: .degrees(180), endAngle: .degrees(45), clockwise: false)
                ctx.stroke(p, with: stroke, style: style)
            case .siren:
                var p = Path()
                p.move(to: CGPoint(x: 6, y: 18))
                p.addLine(to: CGPoint(x: 6, y: 13))
                p.addArc(center: CGPoint(x: 12, y: 13), radius: 6,
                         startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                p.addLine(to: CGPoint(x: 18, y: 18))
                p.move(to: CGPoint(x: 4, y: 18));  p.addLine(to: CGPoint(x: 20, y: 18))
                p.move(to: CGPoint(x: 12, y: 4));  p.addLine(to: CGPoint(x: 12, y: 2))
                ctx.stroke(p, with: stroke, style: style)
            }
        }
        .frame(width: size, height: size)
    }
}
