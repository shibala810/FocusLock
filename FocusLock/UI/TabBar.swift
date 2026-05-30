//
//  TabBar.swift — bottom 4-tab bar with active blob
//

import SwiftUI

struct TabBar: View {
    @Environment(AppState.self) private var app
    @Environment(\.fl) private var fl

    private struct Item {
        let id: MainTab
        let label: String
        let icon: String
    }
    private let items: [Item] = [
        Item(id: .home,     label: "首頁", icon: "home"),
        Item(id: .schedule, label: "排程", icon: "schedule"),
        Item(id: .stats,    label: "戰績", icon: "stats"),
        Item(id: .settings, label: "設定", icon: "settings"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.id) { it in
                let on = app.tab == it.id
                Button { app.tab = it.id } label: {
                    VStack(spacing: 3) {
                        ZStack {
                            if on {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(fl.primarySoft)
                                    .frame(width: 46, height: 36)
                                    .transition(.scale.combined(with: .opacity))
                            }
                            TabIcon(name: it.icon, active: on)
                        }
                        Text(it.label)
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundStyle(on ? fl.primaryDeep : fl.inkFaint)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    .animation(.spring(response: 0.28, dampingFraction: 0.7), value: on)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 6)
        .frame(height: 62)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(fl.surface)
                .modifier(FLShadow.card(fl))
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 22)
        .padding(.top, 8)
        .background(
            LinearGradient(colors: [.clear, fl.bg],
                           startPoint: .top, endPoint: .center)
        )
        .iPadContentWidth(560)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}
