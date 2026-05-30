//
//  TopBar.swift
//

import SwiftUI

struct TopBar<Trailing: View>: View {
    let title: String
    var sub: String? = nil
    var onBack: (() -> Void)? = nil
    @ViewBuilder var trailing: () -> Trailing

    @Environment(\.fl) private var fl

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if let onBack {
                Button(action: onBack) {
                    LineIcon(name: .back, size: 20, color: fl.ink)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle().fill(fl.surface)
                                .modifier(FLShadow.cardSmall(fl))
                        )
                }
                .buttonStyle(.plain)
            }
            VStack(alignment: .leading, spacing: 1) {
                if let sub {
                    Text(sub)
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(fl.primaryDeep)
                }
                Text(title)
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundStyle(fl.ink)
            }
            Spacer()
            trailing()
        }
        .padding(.horizontal, 22)
        .padding(.top, 14)
        .padding(.bottom, 8)
    }
}

extension TopBar where Trailing == EmptyView {
    init(title: String, sub: String? = nil, onBack: (() -> Void)? = nil) {
        self.init(title: title, sub: sub, onBack: onBack, trailing: { EmptyView() })
    }
}
