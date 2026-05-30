//
//  ScheduleScreen.swift
//

import SwiftUI

struct ScheduleScreen: View {
    @Environment(AppState.self) private var app
    @Environment(\.fl) private var fl

    var body: some View {
        FLScreen {
            PawField()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    TopBar(title: "排程", sub: "自動進入專注結界",
                           onBack: nil) {
                        Button {
                            app.editingSchedule = Schedule(name: "", start: "19:00", end: "22:00",
                                                           days: [1,2,3,4,5], enabled: true, friction: true)
                            app.route = .editSchedule
                        } label: {
                            LineIcon(name: .plus, size: 22, color: .white)
                                .frame(width: 42, height: 42)
                                .background(Circle().fill(fl.primary))
                                .shadow(color: fl.primaryDeep.opacity(0.6), radius: 8, y: 5)
                        }.buttonStyle(.plain)
                    }

                    VStack(spacing: 13) {
                        ForEach(app.schedules) { s in
                            scheduleCard(s)
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 10)

                    HStack(spacing: 8) {
                        Paw(size: 18, color: fl.paw)
                        Text("麻糬會準時提醒你進入結界")
                            .font(.system(size: 13))
                            .foregroundStyle(fl.inkFaint)
                    }
                    .padding(.vertical, 24)
                }
                .padding(.bottom, 110)
            }
        }
    }

    @ViewBuilder
    private func scheduleCard(_ s: Schedule) -> some View {
        Button {
            app.editingSchedule = s
            app.route = .editSchedule
        } label: {
            FLCard(cornerRadius: 24) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 12) {
                        LineIcon(name: s.enabled ? .lock : .unlock, size: 22,
                                 color: s.enabled ? fl.primaryDeep : fl.inkFaint)
                            .frame(width: 44, height: 44)
                            .background(RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(s.enabled ? fl.primarySoft : fl.surface3))
                        VStack(alignment: .leading, spacing: 1) {
                            Text(s.name.isEmpty ? "未命名排程" : s.name)
                                .font(.system(size: 17, weight: .heavy))
                                .foregroundStyle(fl.ink)
                            Text("\(s.startTimeString) – \(s.endTimeString)")
                                .font(.system(size: 13.5).monospacedDigit())
                                .foregroundStyle(fl.inkSoft)
                        }
                        Spacer()
                        FLToggle(isOn: Binding(
                            get: { s.enabled },
                            set: { newVal in
                                if let idx = app.schedules.firstIndex(where: { $0.id == s.id }) {
                                    app.schedules[idx].enabled = newVal
                                }
                            }
                        ), color: fl.primary)
                    }
                    HStack(spacing: 6) {
                        ForEach(0..<7, id: \.self) { i in
                            let on = s.days.contains(i)
                            Text(WEEK_LABELS[i])
                                .font(.system(size: 12.5, weight: .heavy))
                                .foregroundStyle(on ? fl.onPrimary : fl.inkFaint)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 7)
                                .background(
                                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                                        .fill(on ? fl.primary : fl.surface3)
                                )
                        }
                    }
                    if s.friction {
                        HStack(spacing: 6) {
                            LineIcon(name: .shield, size: 15, color: fl.amber)
                            Text("已開啟「再想一下」摩擦設計")
                                .font(.system(size: 12.5, weight: .heavy))
                                .foregroundStyle(fl.amber)
                        }
                    }
                }
                .padding(16)
            }
            .opacity(s.enabled ? 1 : 0.62)
        }
        .buttonStyle(.plain)
    }
}
