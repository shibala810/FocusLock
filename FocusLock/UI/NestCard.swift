//
//  NestCard.swift — dashed "貓窩" card
//

import SwiftUI

struct NestCard<Content: View>: View {
    @ViewBuilder var content: () -> Content
    @Environment(\.fl) private var fl

    var body: some View {
        content()
            .padding(22)
            .background(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(fl.surface2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .strokeBorder(fl.paw,
                                  style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
            )
    }
}
