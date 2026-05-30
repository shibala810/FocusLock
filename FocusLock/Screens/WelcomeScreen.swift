//
//  WelcomeScreen.swift
//

import SwiftUI

struct WelcomeScreen: View {
    @Environment(AppState.self) private var app
    @Environment(\.fl) private var fl

    private let steps: [(String, String, String)] = [
        ("1", "選 App",     "挑出會讓你分心的娛樂 App"),
        ("2", "設定鎖定",   "即時開鎖或排程每週時段"),
        ("3", "答題解鎖",   "想偷溜?先答對考題再說"),
    ]

    var body: some View {
        FLScreen {
            PawField()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // hero
                    VStack(spacing: 14) {
                        HStack(spacing: 8) {
                            HeartLock(size: 26, color: fl.primary)
                            Text("FocusLock")
                                .font(.system(size: 17, weight: .heavy))
                                .tracking(0.6)
                                .foregroundStyle(fl.primaryDeep)
                        }

                        ZStack {
                            Blob(color: fl.bgBlob.opacity(0.55))
                                .frame(width: 220, height: 270)
                                .offset(y: 2)
                            Image("Kenma")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 206, height: 248)
                                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                                        .strokeBorder(fl.surface, lineWidth: 3)
                                )
                                .modifier(AnyShadow(.pop(fl)))
                            Volleyball(size: 50, spin: app.spinAnimationEnabled)
                                .offset(x: 88, y: -110)
                                .flFloat()
                            Paw(size: 22, color: fl.paw)
                                .rotationEffect(.degrees(-20))
                                .offset(x: -92, y: 108)
                        }
                        .frame(width: 280, height: 290)
                    }
                    .padding(.top, 56)
                    .padding(.horizontal, 24)

                    VStack(spacing: 12) {
                        (Text("鎖住分心,\n").foregroundStyle(fl.ink)
                         + Text("解鎖靠實力").foregroundStyle(fl.primaryDeep))
                        .font(.system(size: 30, weight: .heavy))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)

                        Text("讓衝動先冷靜下來,順便複習幾題。\n麻糬會陪你一起撐過讀書的時光 🏐")
                            .font(.system(size: 14.5))
                            .foregroundStyle(fl.inkSoft)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 28)

                    VStack(spacing: 10) {
                        ForEach(steps, id: \.0) { (n, t, d) in
                            FLCard(cornerRadius: 22, smallShadow: true) {
                                HStack(spacing: 14) {
                                    Text(n)
                                        .font(.system(size: 18, weight: .heavy))
                                        .foregroundStyle(fl.primaryDeep)
                                        .frame(width: 38, height: 38)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .fill(fl.primarySoft)
                                        )
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(t)
                                            .font(.system(size: 16, weight: .heavy))
                                            .foregroundStyle(fl.ink)
                                        Text(d)
                                            .font(.system(size: 13))
                                            .foregroundStyle(fl.inkSoft)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.horizontal, 22)

                    VStack(spacing: 12) {
                        Button {
                            Task { await requestAuth() }
                        } label: {
                            Text("開始設定")
                        }
                        .buttonStyle(FLCTAStyle())

                        Text("下一步會請求 Apple「螢幕使用時間」授權,\nApp 不會看到你選了哪些 App 的名稱。")
                            .font(.system(size: 11.5))
                            .foregroundStyle(fl.inkFaint)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    private func requestAuth() async {
        await ScreenTimeService.shared.requestAuthorization()
        app.route = .main
    }
}
