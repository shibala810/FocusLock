//
//  Cat.swift — 麻糬 the pink mochi cat (5 moods)
//

import SwiftUI

enum CatMood { case happy, study, sleep, cheer, worry }

struct Cat: View {
    var size: CGFloat = 130
    var mood: CatMood = .happy
    var body: some View {
        let h = size * 116 / 114
        Canvas { ctx, _ in
            let s = size / 114
            let body  = Color(hex: 0xF6C6CF)
            let outline = Color(hex: 0xE8A6B3)
            let dark  = Color(hex: 0x3C2A30)
            let blush = Color(hex: 0xF2899B)

            // ear left
            var earL = Path()
            earL.move(to: CGPoint(x: 30 * s, y: 30 * s))
            earL.addLine(to: CGPoint(x: 24 * s, y: 8 * s))
            earL.addLine(to: CGPoint(x: 46 * s, y: 24 * s))
            earL.closeSubpath()
            ctx.fill(earL, with: .color(body))
            ctx.stroke(earL, with: .color(outline), lineWidth: 2 * s)

            // ear right
            var earR = Path()
            earR.move(to: CGPoint(x: 84 * s, y: 30 * s))
            earR.addLine(to: CGPoint(x: 90 * s, y:  8 * s))
            earR.addLine(to: CGPoint(x: 68 * s, y: 24 * s))
            earR.closeSubpath()
            ctx.fill(earR, with: .color(body))
            ctx.stroke(earR, with: .color(outline), lineWidth: 2 * s)

            // inner ear pink
            var iEarL = Path()
            iEarL.move(to: CGPoint(x: 31 * s, y: 26 * s))
            iEarL.addLine(to: CGPoint(x: 28 * s, y: 14 * s))
            iEarL.addLine(to: CGPoint(x: 40 * s, y: 23 * s))
            iEarL.closeSubpath()
            ctx.fill(iEarL, with: .color(Color(hex: 0xF4A9B6)))
            var iEarR = Path()
            iEarR.move(to: CGPoint(x: 83 * s, y: 26 * s))
            iEarR.addLine(to: CGPoint(x: 86 * s, y: 14 * s))
            iEarR.addLine(to: CGPoint(x: 74 * s, y: 23 * s))
            iEarR.closeSubpath()
            ctx.fill(iEarR, with: .color(Color(hex: 0xF4A9B6)))

            // mochi head
            let head = Path(ellipseIn: CGRect(x: 17 * s, y: 22 * s,
                                              width: 80 * s, height: 76 * s))
            ctx.fill(head, with: .color(body))
            ctx.stroke(head, with: .color(outline), lineWidth: 2 * s)

            // cheeks
            ctx.fill(Path(ellipseIn: CGRect(x: 26 * s, y: 61 * s, width: 14 * s, height: 14 * s)),
                     with: .color(blush.opacity(0.55)))
            ctx.fill(Path(ellipseIn: CGRect(x: 74 * s, y: 61 * s, width: 14 * s, height: 14 * s)),
                     with: .color(blush.opacity(0.55)))

            // nose
            var nose = Path()
            nose.move(to: CGPoint(x: 55 * s, y: 62 * s))
            nose.addLine(to: CGPoint(x: 59 * s, y: 62 * s))
            nose.addLine(to: CGPoint(x: 57 * s, y: 64.4 * s))
            nose.closeSubpath()
            ctx.fill(nose, with: .color(Color(hex: 0xD8657B)))

            // eyes
            let lw = 3.4 * s
            switch mood {
            case .happy:
                ctx.fill(Path(ellipseIn: CGRect(x: 36 * s, y: 54 * s, width: 8 * s, height: 8 * s)),
                         with: .color(dark))
                ctx.fill(Path(ellipseIn: CGRect(x: 70 * s, y: 54 * s, width: 8 * s, height: 8 * s)),
                         with: .color(dark))
                ctx.fill(Path(ellipseIn: CGRect(x: 40 * s, y: 55 * s, width: 2.8 * s, height: 2.8 * s)),
                         with: .color(.white))
                ctx.fill(Path(ellipseIn: CGRect(x: 74 * s, y: 55 * s, width: 2.8 * s, height: 2.8 * s)),
                         with: .color(.white))
            case .study:
                var e1 = Path(); e1.move(to: CGPoint(x: 34 * s, y: 58 * s))
                e1.addQuadCurve(to: CGPoint(x: 46 * s, y: 58 * s), control: CGPoint(x: 40 * s, y: 63 * s))
                var e2 = Path(); e2.move(to: CGPoint(x: 68 * s, y: 58 * s))
                e2.addQuadCurve(to: CGPoint(x: 80 * s, y: 58 * s), control: CGPoint(x: 74 * s, y: 63 * s))
                ctx.stroke(e1, with: .color(dark), style: StrokeStyle(lineWidth: lw, lineCap: .round))
                ctx.stroke(e2, with: .color(dark), style: StrokeStyle(lineWidth: lw, lineCap: .round))
            case .sleep:
                var e1 = Path(); e1.move(to: CGPoint(x: 33 * s, y: 58 * s))
                e1.addQuadCurve(to: CGPoint(x: 47 * s, y: 58 * s), control: CGPoint(x: 40 * s, y: 64 * s))
                var e2 = Path(); e2.move(to: CGPoint(x: 67 * s, y: 58 * s))
                e2.addQuadCurve(to: CGPoint(x: 81 * s, y: 58 * s), control: CGPoint(x: 74 * s, y: 64 * s))
                ctx.stroke(e1, with: .color(dark), style: StrokeStyle(lineWidth: lw, lineCap: .round))
                ctx.stroke(e2, with: .color(dark), style: StrokeStyle(lineWidth: lw, lineCap: .round))
            case .cheer:
                var e1 = Path(); e1.move(to: CGPoint(x: 34 * s, y: 60 * s))
                e1.addQuadCurve(to: CGPoint(x: 46 * s, y: 60 * s), control: CGPoint(x: 40 * s, y: 52 * s))
                var e2 = Path(); e2.move(to: CGPoint(x: 68 * s, y: 60 * s))
                e2.addQuadCurve(to: CGPoint(x: 80 * s, y: 60 * s), control: CGPoint(x: 74 * s, y: 52 * s))
                ctx.stroke(e1, with: .color(dark), style: StrokeStyle(lineWidth: lw, lineCap: .round))
                ctx.stroke(e2, with: .color(dark), style: StrokeStyle(lineWidth: lw, lineCap: .round))
            case .worry:
                ctx.fill(Path(ellipseIn: CGRect(x: 36 * s, y: 55 * s, width: 8 * s, height: 8 * s)),
                         with: .color(dark))
                ctx.fill(Path(ellipseIn: CGRect(x: 70 * s, y: 55 * s, width: 8 * s, height: 8 * s)),
                         with: .color(dark))
                var br1 = Path(); br1.move(to: CGPoint(x: 33 * s, y: 50 * s))
                br1.addLine(to: CGPoint(x: 44 * s, y: 53 * s))
                var br2 = Path(); br2.move(to: CGPoint(x: 81 * s, y: 50 * s))
                br2.addLine(to: CGPoint(x: 70 * s, y: 53 * s))
                ctx.stroke(br1, with: .color(dark), style: StrokeStyle(lineWidth: 2.6 * s, lineCap: .round))
                ctx.stroke(br2, with: .color(dark), style: StrokeStyle(lineWidth: 2.6 * s, lineCap: .round))
            }

            // mouth
            var mouth = Path()
            switch mood {
            case .happy:
                mouth.move(to: CGPoint(x: 52 * s, y: 66 * s))
                mouth.addQuadCurve(to: CGPoint(x: 62 * s, y: 66 * s),
                                   control: CGPoint(x: 57 * s, y: 71 * s))
                ctx.stroke(mouth, with: .color(dark),
                           style: StrokeStyle(lineWidth: 2.6 * s, lineCap: .round))
            case .study:
                mouth.move(to: CGPoint(x: 53 * s, y: 67 * s))
                mouth.addLine(to: CGPoint(x: 61 * s, y: 67 * s))
                ctx.stroke(mouth, with: .color(dark),
                           style: StrokeStyle(lineWidth: 2.6 * s, lineCap: .round))
            case .sleep:
                mouth.move(to: CGPoint(x: 53 * s, y: 67 * s))
                mouth.addQuadCurve(to: CGPoint(x: 61 * s, y: 67 * s),
                                   control: CGPoint(x: 57 * s, y: 70 * s))
                ctx.stroke(mouth, with: .color(dark),
                           style: StrokeStyle(lineWidth: 2.4 * s, lineCap: .round))
            case .cheer:
                mouth.move(to: CGPoint(x: 49 * s, y: 65 * s))
                mouth.addQuadCurve(to: CGPoint(x: 65 * s, y: 65 * s),
                                   control: CGPoint(x: 57 * s, y: 74 * s))
                mouth.addQuadCurve(to: CGPoint(x: 49 * s, y: 65 * s),
                                   control: CGPoint(x: 57 * s, y: 69 * s))
                ctx.fill(mouth, with: .color(Color(hex: 0xE8788D)))
                ctx.stroke(mouth, with: .color(dark),
                           style: StrokeStyle(lineWidth: 2 * s, lineCap: .round))
            case .worry:
                mouth.move(to: CGPoint(x: 52 * s, y: 69 * s))
                mouth.addQuadCurve(to: CGPoint(x: 62 * s, y: 69 * s),
                                   control: CGPoint(x: 57 * s, y: 65 * s))
                ctx.stroke(mouth, with: .color(dark),
                           style: StrokeStyle(lineWidth: 2.6 * s, lineCap: .round))
            }

            // whiskers
            let wh = Color(hex: 0xE8A6B3)
            var wp = Path()
            wp.move(to: CGPoint(x: 18 * s, y: 60 * s)); wp.addLine(to: CGPoint(x: 31 * s, y: 60 * s))
            wp.move(to: CGPoint(x: 18 * s, y: 67 * s)); wp.addLine(to: CGPoint(x: 31 * s, y: 67 * s))
            wp.move(to: CGPoint(x: 96 * s, y: 60 * s)); wp.addLine(to: CGPoint(x: 83 * s, y: 60 * s))
            wp.move(to: CGPoint(x: 96 * s, y: 67 * s)); wp.addLine(to: CGPoint(x: 83 * s, y: 67 * s))
            ctx.stroke(wp, with: .color(wh), style: StrokeStyle(lineWidth: 1.6 * s, lineCap: .round))

            // ZZ for sleep
            if mood == .sleep {
                var z = Path()
                z.move(to: CGPoint(x: 86 * s, y: 22 * s))
                z.addLine(to: CGPoint(x: 94 * s, y: 22 * s))
                z.addLine(to: CGPoint(x: 86 * s, y: 30 * s))
                z.addLine(to: CGPoint(x: 94 * s, y: 30 * s))
                z.move(to: CGPoint(x: 98 * s, y: 12 * s))
                z.addLine(to: CGPoint(x: 103 * s, y: 12 * s))
                z.addLine(to: CGPoint(x: 98 * s, y: 17 * s))
                z.addLine(to: CGPoint(x: 103 * s, y: 17 * s))
                ctx.stroke(z, with: .color(Color(hex: 0x8C6571).opacity(0.85)),
                           style: StrokeStyle(lineWidth: 2.4 * s, lineCap: .round))
            }
        }
        .frame(width: size, height: h)
    }
}
