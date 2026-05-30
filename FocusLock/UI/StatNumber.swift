//
//  StatNumber.swift — shared small "stat card"
//

import SwiftUI

struct MiniStat<Icon: View>: View {
    @ViewBuilder var icon: () -> Icon
    let label: String
    let value: String
    let tint: Color
    @Environment(\.fl) private var fl

    var body: some View {
        FLCard(cornerRadius: 22, smallShadow: true) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 7) {
                    icon().foregroundStyle(tint)
                    Text(label)
                        .font(.system(size: 12.5, weight: .heavy))
                        .foregroundStyle(fl.inkSoft)
                }
                Text(value)
                    .font(.system(size: 22, weight: .heavy).monospacedDigit())
                    .foregroundStyle(fl.ink)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 15)
            .padding(.horizontal, 16)
        }
    }
}
