//
//  ScheduleEditorView.swift
//

import SwiftUI

struct ScheduleEditorView: View {
    @Environment(AppState.self) private var app
    @Environment(\.fl) private var fl

    @State private var draft: Schedule = .init(name: "", start: "19:00", end: "22:00",
                                               days: [1,2,3,4,5], enabled: true, friction: true)
    @State private var startDate: Date = .now
    @State private var endDate:   Date = .now

    private var isNew: Bool { !app.schedules.contains(where: { $0.id == draft.id }) }

    var body: some View {
        FLScreen {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    TopBar(title: isNew ? "新排程" : "編輯排程",
                           onBack: { app.route = .main }) {
                        Button { save() } label: {
                            Text("儲存")
                                .font(.system(size: 14.5, weight: .heavy))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 18).padding(.vertical, 9)
                                .background(Capsule().fill(fl.primary))
                                .shadow(color: fl.primaryDeep.opacity(0.5), radius: 7, y: 4)
                        }.buttonStyle(.plain)
                    }

                    VStack(spacing: 16) {
                        FLCard(cornerRadius: 20) {
                            TextField("排程名稱", text: $draft.name)
                                .font(.system(size: 18, weight: .heavy))
                                .foregroundStyle(fl.ink)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                        }

                        HStack(spacing: 12) {
                            timeCard(label: "開始", date: $startDate) { hm in
                                draft.startHour = hm.h; draft.startMinute = hm.m
                            }
                            timeCard(label: "結束", date: $endDate) { hm in
                                draft.endHour = hm.h; draft.endMinute = hm.m
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("重複")
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundStyle(fl.inkSoft)
                                .padding(.horizontal, 4)
                            HStack(spacing: 7) {
                                ForEach(0..<7, id: \.self) { i in
                                    let on = draft.days.contains(i)
                                    Button {
                                        if on { draft.days.remove(i) } else { draft.days.insert(i) }
                                    } label: {
                                        Text(WEEK_LABELS[i])
                                            .font(.system(size: 15, weight: .heavy))
                                            .foregroundStyle(on ? .white : fl.inkFaint)
                                            .frame(width: 38, height: 38)
                                            .background(
                                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                    .fill(on ? fl.primary : fl.surface)
                                            )
                                            .shadow(color: on ? fl.primaryDeep.opacity(0.4) : fl.cardShadowSmall,
                                                    radius: on ? 6 : 5, y: on ? 5 : 3)
                                    }
                                    .buttonStyle(.plain)
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .padding(.bottom, 6)

                        FLGroup {
                            FLRow(title: "再想一下摩擦設計", sub: "解鎖前需冷靜倒數",
                                  icon: { LineIcon(name: .shield, size: 20, color: fl.amber) },
                                  iconBg: fl.amberSoft,
                                  right: { FLToggle(isOn: $draft.friction, color: fl.amber) },
                                  last: true)
                        }

                        if !isNew {
                            Button {
                                app.schedules.removeAll { $0.id == draft.id }
                                app.route = .main
                            } label: {
                                HStack(spacing: 8) {
                                    LineIcon(name: .trash, size: 18, color: fl.danger)
                                    Text("刪除排程")
                                }
                                .font(.system(size: 15.5, weight: .heavy))
                                .foregroundStyle(fl.danger)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Capsule().fill(fl.dangerSoft))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            if let editing = app.editingSchedule { draft = editing }
            startDate = makeDate(draft.startHour, draft.startMinute)
            endDate   = makeDate(draft.endHour,   draft.endMinute)
        }
    }

    @ViewBuilder
    private func timeCard(label: String, date: Binding<Date>,
                          onChange: @escaping (_ hm: (h: Int, m: Int)) -> Void) -> some View {
        FLCard(cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 12.5, weight: .heavy))
                    .foregroundStyle(fl.inkSoft)
                DatePicker("", selection: date, displayedComponents: [.hourAndMinute])
                    .labelsHidden()
                    .onChange(of: date.wrappedValue) { _, newVal in
                        let comps = Calendar.current.dateComponents([.hour, .minute], from: newVal)
                        onChange((comps.hour ?? 0, comps.minute ?? 0))
                    }
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func makeDate(_ h: Int, _ m: Int) -> Date {
        var c = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        c.hour = h; c.minute = m
        return Calendar.current.date(from: c) ?? .now
    }

    private func save() {
        if let idx = app.schedules.firstIndex(where: { $0.id == draft.id }) {
            app.schedules[idx] = draft
        } else {
            app.schedules.append(draft)
        }
        app.route = .main
    }
}
