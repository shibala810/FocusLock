//
//  Paw.swift — kawaii paw print
//

import SwiftUI

struct Paw: View {
    var size: CGFloat = 22
    var color: Color = .pink

    var body: some View {
        Canvas { ctx, _ in
            let s = size
            func ellipse(_ cx: Double, _ cy: Double, _ rx: Double, _ ry: Double) -> Path {
                Path(ellipseIn: CGRect(x: (cx - rx) * s / 32,
                                       y: (cy - ry) * s / 32,
                                       width:  rx * 2 * s / 32,
                                       height: ry * 2 * s / 32))
            }
            ctx.fill(ellipse(16, 21, 8.4, 7),  with: .color(color))
            ctx.fill(ellipse(7.5, 12.5, 3.1, 3.9), with: .color(color))
            ctx.fill(ellipse(13,  8.2, 3.1, 4.1), with: .color(color))
            ctx.fill(ellipse(19,  8.2, 3.1, 4.1), with: .color(color))
            ctx.fill(ellipse(24.5,12.5, 3.1, 3.9), with: .color(color))
        }
        .frame(width: size, height: size)
    }
}
