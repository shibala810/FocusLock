//
//  WelcomeScreen.swift — 3-page paged onboarding carousel
//

import SwiftUI

struct WelcomeScreen: View {
    @Environment(AppState.self) private var app
    @Environment(\.fl) private var fl
    @State private var page: Int = 0

    var body: some View {
        FLScreen {
            PawField()
            VStack(spacing: 0) {
                TabView(selection: $page) {
                    pageHero.tag(0)
                    pageFriction.tag(1)
                    pageSchedule.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: 14) {
                    dots
                    actionRow
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Pages

    private var pageHero: some View {
        VStack(spacing: 18) {
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
            VStack(spacing: 10) {
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
        }
        .padding(.top, 60)
    }

    private var pageFriction: some View {
        VStack(spacing: 22) {
            ZStack {
                Blob(color: fl.amberSoft)
                    .frame(width: 240, height: 240)
                if app.mascotEnabled {
                    Cat(size: 160, mood: .worry).flWiggle()
                } else {
                    HeartLock(size: 110, color: fl.amber)
                }
            }
            .padding(.top, 30)

            VStack(spacing: 8) {
                Text("解鎖要先靠實力")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundStyle(fl.ink)

                Text("想偷溜?先做完三件事:")
                    .font(.system(size: 14.5))
                    .foregroundStyle(fl.inkSoft)
            }

            VStack(spacing: 10) {
                frictionStep(emoji: "🌬️", title: "冷靜倒數",
                             body: "強制深呼吸幾秒,衝動通常就過了。")
                frictionStep(emoji: "📚", title: "答題複習",
                             body: "從你勾選的科目隨機抽題,全對才放行。")
                frictionStep(emoji: "🚨", title: "緊急按鈕",
                             body: "真的有急事可以用,但會記在統計裡。")
            }
            .padding(.horizontal, 22)
        }
    }

    private var pageSchedule: some View {
        VStack(spacing: 22) {
            ZStack {
                Blob(color: fl.focusSoft)
                    .frame(width: 240, height: 240)
                if app.mascotEnabled {
                    Cat(size: 160, mood: .study).flBreathe()
                } else {
                    LineIcon(name: .clock, size: 110, color: fl.focus)
                }
            }
            .padding(.top, 30)

            VStack(spacing: 8) {
                Text("排程鎖,自動把你關起來")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundStyle(fl.ink)
                    .multilineTextAlignment(.center)

                Text("讀書時段事先排好,時間到自動進入結界,結束自動放你出來。")
                    .font(.system(size: 14.5))
                    .foregroundStyle(fl.inkSoft)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }

            FLCard(cornerRadius: 22, smallShadow: true) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        LineIcon(name: .clock, size: 18, color: fl.primaryDeep)
                        Text("舉例")
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(fl.primaryDeep)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        scheduleExample(name: "晚自習", time: "週一–五 19:00–22:00")
                        scheduleExample(name: "睡前淨化", time: "每天 23:00–06:30")
                    }
                }
                .padding(16)
            }
            .padding(.horizontal, 22)
        }
    }

    // MARK: - Components

    @ViewBuilder
    private func frictionStep(emoji: String, title: String, body: String) -> some View {
        FLCard(cornerRadius: 20, smallShadow: true) {
            HStack(spacing: 14) {
                Text(emoji)
                    .font(.system(size: 26))
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(fl.amberSoft)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(fl.ink)
                    Text(body)
                        .font(.system(size: 13))
                        .foregroundStyle(fl.inkSoft)
                }
                Spacer(minLength: 4)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
        }
    }

    @ViewBuilder
    private func scheduleExample(name: String, time: String) -> some View {
        HStack(spacing: 9) {
            LineIcon(name: .lock, size: 14, color: fl.primary)
            Text(name)
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(fl.ink)
            Spacer()
            Text(time)
                .font(.system(size: 12.5).monospacedDigit())
                .foregroundStyle(fl.inkSoft)
        }
    }

    private var dots: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(i == page ? fl.primary : fl.surface3)
                    .frame(width: i == page ? 22 : 8, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: page)
            }
        }
    }

    @ViewBuilder
    private var actionRow: some View {
        if page < 2 {
            VStack(spacing: 8) {
                Button { withAnimation { page += 1 } } label: {
                    Text("下一步")
                }
                .buttonStyle(FLCTAStyle())

                Button { Task { await skipToApp() } } label: {
                    Text("跳過,直接開始")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(fl.inkSoft)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
        } else {
            VStack(spacing: 12) {
                Button { Task { await skipToApp() } } label: {
                    Text("開始設定")
                }
                .buttonStyle(FLCTAStyle())

                Text("下一步會請求 Apple「螢幕使用時間」+ 通知授權,\nApp 不會看到你選了哪些 App 的名稱。")
                    .font(.system(size: 11.5))
                    .foregroundStyle(fl.inkFaint)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
        }
    }

    private func skipToApp() async {
        await ScreenTimeService.shared.requestAuthorization()
        await NotificationService.shared.requestAuthorization()
        app.welcomeShown = true
        app.route = .main
    }
}
