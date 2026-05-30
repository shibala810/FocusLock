//
//  SettingsScreen.swift
//

import SwiftUI

struct SettingsScreen: View {
    @Environment(AppState.self) private var app
    @Environment(\.fl) private var fl
    @State private var showProfileEditor = false

    private let allSubjects = Subject.allCases

    private var profileSubtitle: String {
        let school = app.targetSchool.isEmpty ? "尚未設定目標" : "目標:\(app.targetSchool)"
        if let days = app.daysUntilExam {
            return "\(school) · 倒數 \(days) 天"
        }
        return "\(school) · 尚未設定考試日"
    }

    private var footerLine: String {
        let school = app.targetSchool.trimmingCharacters(in: .whitespacesAndNewlines)
        return school.isEmpty
            ? "繼續加油喵,目標就在前方"
            : "為了上\(school),一起加油喵"
    }

    var body: some View {
        @Bindable var bApp = app
        FLScreen {
            PawField()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    TopBar(title: "設定", sub: "把規則調成你的樣子")

                    VStack(spacing: 22) {
                        // profile (tap to edit)
                        Button { showProfileEditor = true } label: {
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
                                        Text("準考生・\(app.userName)")
                                            .font(.system(size: 18, weight: .heavy))
                                            .foregroundStyle(fl.ink)
                                        Text(profileSubtitle)
                                            .font(.system(size: 13))
                                            .foregroundStyle(fl.inkSoft)
                                            .lineLimit(2)
                                    }
                                    Spacer(minLength: 4)
                                    LineIcon(name: .chevron, size: 16, color: fl.inkFaint)
                                }
                                .padding(18)
                            }
                        }
                        .buttonStyle(.plain)

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
                                footer: "提高題數或拉長冷靜倒數能讓提前解鎖更困難。每日上限設 0 = 不限。") {
                            FLRow(title: "解鎖需答對題數", sub: "冷靜倒數後的考驗",
                                  icon: { LineIcon(name: .book, size: 20, color: fl.focus) },
                                  iconBg: fl.focusSoft,
                                  right: {
                                FLStepper(value: Binding(
                                    get: { app.unlockSettings.needCorrect },
                                    set: { app.unlockSettings.needCorrect = $0 }
                                ), range: 1...5, suffix: " 題")
                            })
                            FLRow(title: "冷靜倒數", sub: "按下解鎖後強制等待",
                                  icon: { LineIcon(name: .breath, size: 20, color: fl.focus) },
                                  iconBg: fl.focusSoft,
                                  right: {
                                FLStepper(value: Binding(
                                    get: { app.unlockSettings.cooldownSeconds },
                                    set: { app.unlockSettings.cooldownSeconds = $0 }
                                ), range: 0...900, step: 15, suffix: " 秒")
                            })
                            FLRow(title: "每日提前解鎖上限", sub: "答題 + 緊急合計;用完當天不能再開",
                                  icon: { LineIcon(name: .siren, size: 20, color: fl.amber) },
                                  iconBg: fl.amberSoft,
                                  right: {
                                FLStepper(value: Binding(
                                    get: { app.unlockSettings.dailyLimit },
                                    set: { app.unlockSettings.dailyLimit = $0 }
                                ), range: 0...10, suffix: " 次")
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
                            FLRow(title: "排程提醒", sub: "啟用後會在排程開始前推播",
                                  icon: { LineIcon(name: .bell, size: 20, color: fl.amber) },
                                  iconBg: fl.amberSoft,
                                  right: {
                                FLToggle(isOn: Binding(
                                    get: { app.notificationsEnabled },
                                    set: { newVal in
                                        app.notificationsEnabled = newVal
                                        if newVal {
                                            Task { await NotificationService.shared.requestAuthorization() }
                                        }
                                    }
                                ), color: fl.amber)
                            })
                            if app.notificationsEnabled {
                                FLRow(title: "提前提醒", sub: "排程開始前的提醒時間",
                                      icon: { LineIcon(name: .clock, size: 20, color: fl.amber) },
                                      iconBg: fl.amberSoft,
                                      right: {
                                    FLStepper(value: Binding(
                                        get: { app.notifyMinutesBefore },
                                        set: { app.notifyMinutesBefore = $0 }
                                    ), range: 1...60, suffix: " 分")
                                })
                            }
                            FLRow(title: "題庫", sub: "瀏覽、匯入自訂題目",
                                  icon: { LineIcon(name: .book, size: 20, color: fl.focus) },
                                  iconBg: fl.focusSoft,
                                  right: { LineIcon(name: .chevron, size: 18, color: fl.inkFaint) },
                                  onTap: { app.route = .questionBank })
                            FLRow(title: "關於 FocusLock", sub: "版本 1.0 ・ 麻糬出品",
                                  icon: { LineIcon(name: .info, size: 20, color: fl.inkSoft) },
                                  right: { LineIcon(name: .chevron, size: 18, color: fl.inkFaint) },
                                  last: true)
                        }

                        HStack(spacing: 7) {
                            Paw(size: 16, color: fl.paw)
                            Text(footerLine)
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
        .sheet(isPresented: $showProfileEditor) {
            ProfileEditorSheet(
                name: app.userName,
                school: app.targetSchool,
                date: app.examDate ?? defaultExamDate(),
                hasDate: app.examDate != nil,
                onCancel: { showProfileEditor = false },
                onSave: { newName, newSchool, newDate, dateOn in
                    app.userName = newName.isEmpty ? "考生" : newName
                    app.targetSchool = newSchool
                    app.examDate = dateOn ? newDate : nil
                    showProfileEditor = false
                }
            )
        }
    }

    private func defaultExamDate() -> Date {
        // Default to next July 1 (台灣大學考分發放榜大約落在 7 月初)
        let cal = Calendar.current
        let now = Date()
        var comps = cal.dateComponents([.year], from: now)
        comps.month = 7
        comps.day = 1
        let thisYear = cal.date(from: comps) ?? now
        if thisYear > now { return thisYear }
        comps.year = (comps.year ?? cal.component(.year, from: now)) + 1
        return cal.date(from: comps) ?? now
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

// MARK: - Profile editor sheet

struct ProfileEditorSheet: View {
    @State var name: String
    @State var school: String
    @State var date: Date
    @State var hasDate: Bool
    var onCancel: () -> Void
    var onSave: (_ name: String, _ school: String, _ date: Date, _ dateOn: Bool) -> Void

    @Environment(\.fl) private var fl

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("取消") { onCancel() }
                    .foregroundStyle(fl.inkSoft)
                    .font(.system(size: 16, weight: .heavy))
                Spacer()
                Text("編輯個人資料")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(fl.ink)
                Spacer()
                Button("儲存") { onSave(name, school, date, hasDate) }
                    .foregroundStyle(fl.primaryDeep)
                    .font(.system(size: 16, weight: .heavy))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Divider().background(fl.hairline)

            ScrollView {
                VStack(spacing: 16) {
                    field(label: "名字", placeholder: "輸入你的名字", text: $name)
                    field(label: "目標學校", placeholder: "例如:台灣大學", text: $school)

                    FLCard(cornerRadius: 18, smallShadow: true) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("考試日期")
                                    .font(.system(size: 13, weight: .heavy))
                                    .foregroundStyle(fl.inkSoft)
                                Spacer()
                                FLToggle(isOn: $hasDate, color: fl.primary)
                            }
                            if hasDate {
                                DatePicker("", selection: $date, in: Date()...,
                                           displayedComponents: [.date])
                                    .datePickerStyle(.graphical)
                                    .labelsHidden()
                                    .tint(fl.primaryDeep)
                                Text("距離考試 \(daysAway()) 天")
                                    .font(.system(size: 13))
                                    .foregroundStyle(fl.primaryDeep)
                            } else {
                                Text("關閉後不顯示倒數")
                                    .font(.system(size: 13))
                                    .foregroundStyle(fl.inkFaint)
                            }
                        }
                        .padding(16)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
        }
        .background(fl.bg)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private func field(label: String, placeholder: String, text: Binding<String>) -> some View {
        FLCard(cornerRadius: 18, smallShadow: true) {
            VStack(alignment: .leading, spacing: 6) {
                Text(label)
                    .font(.system(size: 12.5, weight: .heavy))
                    .foregroundStyle(fl.inkSoft)
                TextField(placeholder, text: text)
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(fl.ink)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding(14)
        }
    }

    private func daysAway() -> Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let target = cal.startOfDay(for: date)
        return max(0, cal.dateComponents([.day], from: today, to: target).day ?? 0)
    }
}
