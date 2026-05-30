//
//  HomeScreen.swift — locked vs unlocked
//

import SwiftUI

private struct Duration: Identifiable { let id = UUID(); let label: String; let minutes: Int }
private let DURATIONS: [Duration] = [
    .init(label: "30 分", minutes: 30),
    .init(label: "1 時",  minutes: 60),
    .init(label: "2 時",  minutes: 120),
    .init(label: "3 時",  minutes: 180),
]

struct HomeScreen: View {
    @Environment(AppState.self) private var app
    @Environment(\.fl) private var fl
    @State private var pickedMinutes: Int = 60
    @State private var showCustomSheet: Bool = {
        #if DEBUG
        return UserDefaults.standard.bool(forKey: "FL_CUSTOM_SHEET")
        #else
        return false
        #endif
    }()
    @State private var customHours: Int = 0
    @State private var customMinutes: Int = 45

    var body: some View {
        let locked = app.lockSession.state == .locked
        FLScreen {
            if !locked { PawField() }
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    greeting(locked: locked)
                    if locked { lockedBody } else { unlockedBody }
                    todayStats
                }
                .padding(.bottom, 110)
            }
        }
        .sheet(isPresented: $showCustomSheet) {
            CustomDurationSheet(
                hours: $customHours,
                minutes: $customMinutes,
                onCancel: { showCustomSheet = false },
                onConfirm: { total in
                    pickedMinutes = total
                    showCustomSheet = false
                }
            )
        }
    }

    @ViewBuilder
    private func greeting(locked: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("哈囉,\(app.userName) 👋")
                    .font(.system(size: 13.5, weight: .heavy))
                    .foregroundStyle(fl.primaryDeep)
                Text(locked ? "專注結界中" : "今天也加油")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundStyle(fl.ink)
            }
            Spacer()
            if app.mascotEnabled {
                Cat(size: 76, mood: locked ? .study : .happy)
                    .offset(y: -4)
                    .flBreathe(duration: 4)
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 16)
        .padding(.bottom, 16)
    }

    // ---------- LOCKED ----------
    @ViewBuilder
    private var lockedBody: some View {
        VStack(spacing: 0) {
            VStack(spacing: 18) {
                // Volleyball, breathing on its own backdrop blob.
                ZStack {
                    Blob(color: fl.surface2)
                        .frame(width: 240, height: 240)
                    Volleyball(size: 180, spin: app.spinAnimationEnabled)
                        .flBreathe(duration: 5)
                }
                .padding(.top, 4)

                // Timer card — fully separate, easy to read.
                VStack(spacing: 6) {
                    Text(LockSession.fmt(app.lockSession.remainingSeconds))
                        .font(.system(size: 48, weight: .heavy).monospacedDigit())
                        .foregroundStyle(fl.ink)
                        .kerning(1.2)
                    Text("剩餘鎖定")
                        .font(.system(size: 12.5, weight: .heavy))
                        .tracking(3)
                        .foregroundStyle(fl.inkSoft)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(fl.surface)
                )
                .modifier(FLShadow.cardSmall(fl))
                .padding(.horizontal, 22)

                HStack(spacing: 7) {
                    LineIcon(name: .shield, size: 16, color: fl.focus)
                    Text("已封鎖 \(app.blockCount) 個 App・心無旁騖")
                        .font(.system(size: 13.5, weight: .heavy))
                        .foregroundStyle(fl.focus)
                }
                .padding(.horizontal, 15).padding(.vertical, 7)
                .background(Capsule().fill(fl.focusSoft))
            }
            .padding(.top, 8)

            Text("娛樂 App 現在打不開囉。\n真的有需要,可以答題提前解鎖。")
                .font(.system(size: 14))
                .foregroundStyle(fl.inkSoft)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.vertical, 14)
                .padding(.horizontal, 28)

            Button { app.route = .unlock } label: {
                HStack(spacing: 8) {
                    LineIcon(name: .unlock, size: 20, color: fl.amber)
                    Text("我要提前解鎖").foregroundStyle(fl.amber)
                }
                .font(.system(size: 16, weight: .heavy))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 28)
                .background(Capsule().fill(fl.surface))
                .modifier(FLShadow.cardSmall(fl))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 22)
        }
    }

    // ---------- UNLOCKED ----------
    @ViewBuilder
    private var unlockedBody: some View {
        VStack(spacing: 14) {
            FLCard(cornerRadius: 30) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 9) {
                        Volleyball(size: 28, spin: false)
                        Text("即時鎖定")
                            .font(.system(size: 17, weight: .heavy))
                            .foregroundStyle(fl.ink)
                    }
                    Text("選一段時長,馬上進入專注結界")
                        .font(.system(size: 13))
                        .foregroundStyle(fl.inkSoft)
                        .padding(.top, 4)
                        .padding(.bottom, 16)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4),
                              spacing: 8) {
                        ForEach(DURATIONS) { d in
                            let on = pickedMinutes == d.minutes
                            Button { pickedMinutes = d.minutes } label: {
                                Text(d.label)
                                    .font(.system(size: 14.5, weight: .heavy))
                                    .foregroundStyle(on ? fl.onPrimary : fl.ink)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 11)
                                    .background(
                                        Capsule().fill(on ? fl.primary : fl.surface3)
                                    )
                                    .shadow(color: on ? fl.primaryDeep.opacity(0.4) : .clear, radius: 6, y: 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Button {
                        // Prefill the picker with whatever's chosen now.
                        customHours = pickedMinutes / 60
                        customMinutes = pickedMinutes % 60
                        showCustomSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Text(isCustomDuration ? "已自訂・\(durationLabel(pickedMinutes))" : "自訂時長…")
                            if isCustomDuration {
                                LineIcon(name: .clock, size: 14, color: fl.primaryDeep)
                            }
                        }
                        .font(.system(size: 13.5, weight: .heavy))
                        .foregroundStyle(fl.primaryDeep)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .overlay(
                            Capsule().strokeBorder(fl.paw,
                                                   style: StrokeStyle(lineWidth: 1.5,
                                                                       dash: isCustomDuration ? [] : [5, 4]))
                        )
                        .background(
                            Capsule().fill(isCustomDuration ? fl.primarySoft : .clear)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 10)

                    Button {
                        startLock()
                    } label: {
                        Text("立即鎖定 · \(durationLabel(pickedMinutes))")
                    }
                    .buttonStyle(FLCTAStyle())
                    .padding(.top, 14)
                }
                .padding(20)
            }

            // block target
            Button { app.route = .block } label: {
                FLCard(cornerRadius: 22, smallShadow: true) {
                    HStack(spacing: 13) {
                        LineIcon(name: .shield, size: 22, color: fl.danger)
                            .frame(width: 40, height: 40)
                            .background(RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .fill(fl.dangerSoft))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("封鎖對象")
                                .font(.system(size: 15.5, weight: .heavy))
                                .foregroundStyle(fl.ink)
                            Text("已選擇 \(app.blockCount) 個 App・\(app.categoryCount) 個類別")
                                .font(.system(size: 13))
                                .foregroundStyle(fl.inkSoft)
                        }
                        Spacer()
                        LineIcon(name: .chevron, size: 18, color: fl.inkFaint)
                    }
                    .padding(.vertical, 15)
                    .padding(.horizontal, 18)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 22)
    }

    @ViewBuilder
    private var todayStats: some View {
        HStack(spacing: 12) {
            MiniStat(icon: { LineIcon(name: .clock, size: 16, color: fl.primaryDeep) },
                     label: "今日專注",
                     value: "\(app.todayFocusMinutes / 60) 時 \(app.todayFocusMinutes % 60) 分",
                     tint: fl.primaryDeep)
            MiniStat(icon: { LineIcon(name: .flame, size: 16, color: fl.amber) },
                     label: "連續達標",
                     value: "\(app.streak) 天",
                     tint: fl.amber)
        }
        .padding(.horizontal, 22)
        .padding(.top, 16)
    }

    private func startLock() {
        app.lockSession.lock(forMinutes: pickedMinutes)
        Task { await ScreenTimeService.shared.startShield() }
    }

    private var isCustomDuration: Bool {
        !DURATIONS.contains(where: { $0.minutes == pickedMinutes })
    }
    private func durationLabel(_ m: Int) -> String {
        if let preset = DURATIONS.first(where: { $0.minutes == m }) { return preset.label }
        let h = m / 60, r = m % 60
        if h == 0 { return "\(r) 分" }
        if r == 0 { return "\(h) 時" }
        return "\(h) 時 \(r) 分"
    }
}

// MARK: - Custom duration sheet
struct CustomDurationSheet: View {
    @Binding var hours: Int
    @Binding var minutes: Int
    var onCancel: () -> Void
    var onConfirm: (_ totalMinutes: Int) -> Void

    @Environment(\.fl) private var fl

    var body: some View {
        let total = max(5, hours * 60 + minutes)
        VStack(spacing: 0) {
            HStack {
                Button("取消") { onCancel() }
                    .foregroundStyle(fl.inkSoft)
                    .font(.system(size: 16, weight: .heavy))
                Spacer()
                Text("自訂時長")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(fl.ink)
                Spacer()
                Button("套用") { onConfirm(total) }
                    .foregroundStyle(fl.primaryDeep)
                    .font(.system(size: 16, weight: .heavy))
                    .disabled(total < 5)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Divider().background(fl.hairline)

            VStack(spacing: 14) {
                Text("\(durationText(total))")
                    .font(.system(size: 32, weight: .heavy).monospacedDigit())
                    .foregroundStyle(fl.primaryDeep)
                    .padding(.top, 14)

                HStack(spacing: 0) {
                    Picker("時", selection: $hours) {
                        ForEach(0...8, id: \.self) { Text("\($0) 時").tag($0) }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)

                    Picker("分", selection: $minutes) {
                        ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) {
                            Text("\($0) 分").tag($0)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 180)

                Text("最短 5 分,最長 8 時")
                    .font(.system(size: 12))
                    .foregroundStyle(fl.inkFaint)
                    .padding(.bottom, 16)
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .background(fl.bg)
        .presentationDetents([.height(380)])
        .presentationDragIndicator(.visible)
    }

    private func durationText(_ m: Int) -> String {
        let h = m / 60, r = m % 60
        if h == 0 { return "\(r) 分" }
        if r == 0 { return "\(h) 時" }
        return "\(h) 時 \(r) 分"
    }
}
