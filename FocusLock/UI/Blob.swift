//
//  Blob.swift — morphing soft blob (background hero shape)
//

import SwiftUI

struct BlobShape: Shape {
    var morph: CGFloat   // 0...1
    var animatableData: CGFloat {
        get { morph } set { morph = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        // Interpolate between two corner-radius profiles
        // A: 46% 54% 58% 42% / 54% 46% 58% 42%
        // B: 56% 44% 42% 58% / 44% 58% 42% 56%
        let A: [CGFloat] = [0.46, 0.54, 0.58, 0.42, 0.54, 0.46, 0.58, 0.42]
        let B: [CGFloat] = [0.56, 0.44, 0.42, 0.58, 0.44, 0.58, 0.42, 0.56]
        let r: [CGFloat] = zip(A, B).map { $0 + ($1 - $0) * morph }

        // 8 control points (per CSS border-radius shorthand)
        let tl = CGPoint(x: 0,           y: r[0] * h)
        let tr = CGPoint(x: r[1] * w,    y: 0)
        let rt = CGPoint(x: w,           y: r[2] * h)
        var p = Path()
        p.move(to: tl)
        p.addQuadCurve(to: tr, control: CGPoint(x: 0, y: 0))
        p.addQuadCurve(to: rt, control: CGPoint(x: w, y: 0))
        p.addQuadCurve(to: CGPoint(x: w - r[6] * w, y: h),
                       control: CGPoint(x: w, y: h))
        p.addQuadCurve(to: CGPoint(x: 0, y: h - r[4] * h),
                       control: CGPoint(x: 0, y: h))
        p.closeSubpath()
        return p
    }
}

struct Blob: View {
    var color: Color
    var animate: Bool = true
    @State private var morph: CGFloat = 0

    var body: some View {
        BlobShape(morph: morph)
            .fill(color)
            .onAppear {
                guard animate else { return }
                withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                    morph = 1
                }
            }
    }
}
