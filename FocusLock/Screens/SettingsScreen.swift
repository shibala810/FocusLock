//
//  SettingsScreen.swift
//

import SwiftUI

struct SettingsScreen: View {
    @Environment(AppState.self) private var app
    @Environment(\.fl) private var fl

    private let allSubjects = Subject.allCases

    var body: some View {
        @Bindable var bApp = app
        FLScreen {
            PawField()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    TopBar(title: "設定", sub: "把規則調成你的樣子")

                    VStack(spacing: 22) {
                        // profile
                        FLCard(cornerRadius: 26) {
                            HStack(spacing: 15) {
                                ZStack(alignment: .bottomTrailing) {
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .fill(fl.primarySoft)
                                        .frame(width: 64, height: 64)
                                        .overlay(Cat(size: 56, mood: .happy))
                                    Volleyball(size: 26)
                                        .offset(x: 4, y: 4)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("準考生・小晴")
                                        .font(.system(size: 18, weight: .heavy))
                                    Text("目標:台灣大學 · 倒數 248 天")
                                        .font(.system(size: 13))
                                        .foregroundStyle(fl.inkSoft)
                                }
                                Spacer()
                            }
                            .padding(18)
                        }

                        // appearance
                        FLGroup(header: "外觀") {
                            FLRow(title: "深色模式", sub: "夜讀更護眼",
                                  icon: { LineIcon(name: .heart, size: 20, color: fl.primaryDeep) },
                                  right: {
                                FLToggle(isOn: Binding(
                                    get: { app.theme == .dark },
                                    set: { app.theme = $0 ? .dark : .light }
                                ), color: fl.primary)
                            })
                            FLRow(title: "麻糬陪讀夥伴", sub: "在各畫面顯示貓咪吉祥物",
                                  icon: { Paw(size: 20, color: fl.paw) },
                                  iconBg: fl.primarySoft,
                                  right: { FLToggle(isOn: $bApp.mascotEnabled, color: fl.primary) },
                                  last: true)
                        }

                        // unlock difficulty
                        FLGroup(header: "解鎖難度",
                                footer: "提高題數會讓提前解鎖更困難 —— 越難,越能逼自己專注。") {
                            FLRow(title: "解鎖需答對題數", sub: "冷靜倒數後的考驗",
                                  icon: { LineIcon(name: .book, size: 20, color: fl.focus) },
                                  iconBg: fl.focusSoft,
                                  right: {
                                FLStepper(value: Binding(
                                    get: { app.unlockSettings.needCorrect },
                                    set: { app.unlockSettings.needCorrect = $0 }
                                ), range: 1...5, suffix: " 題")
                            },
                                  last: true)
                        }

                        // subjects (2x2 grid)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("出題科目")
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundStyle(fl.inkSoft)
                                .padding(.horizontal, 14)
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10),
                                                GridItem(.flexible(), spacing: 10)], spacing: 10) {
                                ForEach(allSubjects) { s in
                                    subjectChip(s)
                                }
                            }
                            Text("題目涵蓋高一至高二範圍,解鎖時隨機抽取。")
                                .font(.system(size: 12))
                                .foregroundStyle(fl.inkFaint)
                                .padding(.horizontal, 14)
                                .padding(.top, 4)
                        }
                        .padding(.bottom, 4)

                        FLGroup(header: "其他") {
                            FLRow(title: "封鎖對象", sub: "管理要鎖的 App",
                                  icon: { LineIcon(name: .shield, size: 20, color: fl.danger) },
                                  iconBg: fl.dangerSoft,
                                  right: { LineIcon(name: .chevron, size: 18, color: fl.inkFaint) },
                                  onTap: { app.route = .block })
                            FLRow(title: "提醒通知", sub: "排程開始前提醒",
                                  icon: { LineIcon(name: .bell, size: 20, color: fl.amber) },
                                  iconBg: fl.amberSoft,
                                  right: { FLToggle(isOn: .constant(true), color: fl.amber) })
                            FLRow(title: "關於 FocusLock", sub: "版本 1.0 ・ 麻糬出品",
                                  icon: { LineIcon(name: .info, size: 20, color: fl.inkSoft) },
                                  right: { LineIcon(name: .chevron, size: 18, color: fl.inkFaint) },
                                  last: true)
                        }

                        HStack(spacing: 7) {
                            Paw(size: 16, color: fl.paw)
                            Text("為了上台大,一起加油喵")
                                .font(.system(size: 12.5))
                                .foregroundStyle(fl.inkFaint)
                        }
                        .padding(.bottom, 34)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 8)
                    .padding(.bottom, 110)
                }
            }
        }
    }

    @ViewBuilder
    private func subjectChip(_ s: Subject) -> some View {
        let on = app.unlockSettings.subjects.contains(s)
        Button {
            if on, app.unlockSettings.subjects.count > 1 {
                app.unlockSettings.subjects.remove(s)
            } else {
                app.unlockSettings.subjects.insert(s)
            }
        } label: {
            HStack(spacing: 11) {
                SubjectIcon(subject: s, size: 36)
                VStack(alignment: .leading, spacing: 1) {
                    Text(s.rawValue)
                        .font(.system(size: 15.5, weight: .heavy))
                        .foregroundStyle(fl.ink)
                    Text("\(app.bank.counts()[s] ?? 0) 題庫")
                        .font(.system(size: 11.5))
                        .foregroundStyle(fl.inkSoft)
                }
                Spacer()
                if on {
                    LineIcon(name: .check, size: 18, color: s.color)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(on ? s.soft : fl.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(on ? s.color : .clear, lineWidth: 2)
            )
            .modifier(FLShadow.cardSmall(fl))
        }
        .buttonStyle(.plain)
    }
}
