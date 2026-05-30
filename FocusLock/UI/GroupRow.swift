//
//  GroupRow.swift — settings-style grouped list
//

import SwiftUI

struct FLGroup<Content: View>: View {
    var header: String? = nil
    var footer: String? = nil
    @ViewBuilder var content: () -> Content
    @Environment(\.fl) private var fl

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let header {
                Text(header)
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(fl.inkSoft)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 8)
            }
            VStack(spacing: 0) { content() }
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(fl.surface)
                )
                .modifier(FLShadow.card(fl))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            if let footer {
                Text(footer)
                    .font(.system(size: 12))
                    .foregroundStyle(fl.inkFaint)
                    .lineSpacing(2)
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
            }
        }
        .padding(.bottom, 22)
    }
}

struct FLRow<Right: View, Icon: View>: View {
    let title: String
    var sub: String? = nil
    @ViewBuilder var icon: () -> Icon
    var iconBg: Color? = nil
    @ViewBuilder var right: () -> Right
    var onTap: (() -> Void)? = nil
    var last: Bool = false
    @Environment(\.fl) private var fl

    var body: some View {
        HStack(spacing: 13) {
            ZStack { icon() }
                .frame(width: 34, height: 34)
                .background(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(iconBg ?? fl.surface3)
                )
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 15.5, weight: .heavy))
                    .foregroundStyle(fl.ink)
                if let sub {
                    Text(sub)
                        .font(.system(size: 12.5))
                        .foregroundStyle(fl.inkSoft)
                }
            }
            Spacer()
            right()
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 16)
        .background(fl.surface)
        .overlay(alignment: .bottom) {
            if !last {
                Rectangle().fill(fl.hairline).frame(height: 1)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
    }
}

extension FLRow where Right == EmptyView {
    init(title: String, sub: String? = nil,
         @ViewBuilder icon: @escaping () -> Icon,
         iconBg: Color? = nil,
         onTap: (() -> Void)? = nil,
         last: Bool = false) {
        self.init(title: title, sub: sub, icon: icon, iconBg: iconBg,
                  right: { EmptyView() }, onTap: onTap, last: last)
    }
}
