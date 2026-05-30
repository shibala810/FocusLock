//
//  TabIcon.swift
//

import SwiftUI

struct TabIcon: View {
    let name: String   // home / schedule / stats / settings
    let active: Bool
    @Environment(\.fl) private var fl

    var color: Color { active ? fl.primaryDeep : fl.inkFaint }
    var sw: CGFloat = 2.2
    var size: CGFloat = 26

    var body: some View {
        ZStack {
            switch name {
            case "home":
                Path { p in
                    p.move(to: CGPoint(x: 4, y: 11.5))
                    p.addLine(to: CGPoint(x: 12, y: 4))
                    p.addLine(to: CGPoint(x: 20, y: 11.5))
                    p.move(to: CGPoint(x: 6, y: 10.5))
                    p.addLine(to: CGPoint(x: 6, y: 20))
                    p.addLine(to: CGPoint(x: 18, y: 20))
                    p.addLine(to: CGPoint(x: 18, y: 10.5))
                }
                .scaledStroke(size: size, sw: sw, color: color)
                if active {
                    Circle().fill(color).frame(width: size * 4 / 24, height: size * 4 / 24)
                        .offset(y: size * 3 / 24)
                }

            case "schedule":
                Path { p in
                    p.addRoundedRect(in: CGRect(x: 4, y: 5, width: 16, height: 16),
                                     cornerSize: CGSize(width: 4, height: 4))
                    p.move(to: CGPoint(x: 4, y: 9.5)); p.addLine(to: CGPoint(x: 20, y: 9.5))
                    p.move(to: CGPoint(x: 8, y: 3));  p.addLine(to: CGPoint(x: 8, y: 7))
                    p.move(to: CGPoint(x: 16, y: 3)); p.addLine(to: CGPoint(x: 16, y: 7))
                }
                .scaledStroke(size: size, sw: sw, color: color)
                if active {
                    Circle().fill(color).frame(width: size * 4 / 24, height: size * 4 / 24)
                        .offset(y: size * 3 / 24)
                }

            case "stats":
                Path { p in
                    p.move(to: CGPoint(x: 5,  y: 20)); p.addLine(to: CGPoint(x: 5,  y: 11))
                    p.move(to: CGPoint(x: 12, y: 20)); p.addLine(to: CGPoint(x: 12, y: 5))
                    p.move(to: CGPoint(x: 19, y: 20)); p.addLine(to: CGPoint(x: 19, y: 14))
                }
                .scaledStroke(size: size, sw: sw, color: color)

            case "settings":
                ZStack {
                    Circle()
                        .stroke(color, style: StrokeStyle(lineWidth: sw * size / 24, lineCap: .round))
                        .frame(width: size * 6.4 / 24, height: size * 6.4 / 24)
                    Path { p in
                        let pts: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                            (12, 3, 12, 5.5),     (12, 18.5, 12, 21),
                            (3, 12, 5.5, 12),     (18.5, 12, 21, 12),
                            (5.6, 5.6, 7.4, 7.4), (16.6, 16.6, 18.4, 18.4),
                            (18.4, 5.6, 16.6, 7.4), (7.4, 16.6, 5.6, 18.4)
                        ]
                        for (x1, y1, x2, y2) in pts {
                            p.move(to: CGPoint(x: x1, y: y1))
                            p.addLine(to: CGPoint(x: x2, y: y2))
                        }
                    }
                    .scaledStroke(size: size, sw: sw, color: color)
                }
            default:
                EmptyView()
            }
        }
        .frame(width: size, height: size)
    }
}

private extension Path {
    func scaledStroke(size: CGFloat, sw: CGFloat, color: Color) -> some View {
        // Scale a 24-unit path to `size`.
        self
            .applying(.init(scaleX: size / 24, y: size / 24))
            .stroke(color, style: StrokeStyle(lineWidth: sw * size / 24,
                                              lineCap: .round, lineJoin: .round))
            .frame(width: size, height: size)
    }
}
