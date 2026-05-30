//
//  Layout.swift — iPad/regular size-class adjustments
//

import SwiftUI

/// Centers content at a sensible max width on iPad / regular-width
/// horizontal size classes. On iPhone this is a no-op.
///
/// Applied near the root (FLScreen) so the gradient background still fills
/// the whole iPad screen, while the foreground card column stays narrow
/// and centered.
struct IPadContentWidthModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var hSize
    var max: CGFloat = 640

    func body(content: Content) -> some View {
        if hSize == .regular {
            content
                .frame(maxWidth: max)
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            content
        }
    }
}

extension View {
    func iPadContentWidth(_ max: CGFloat = 640) -> some View {
        modifier(IPadContentWidthModifier(max: max))
    }
}
