//
//  UnlockFlowView.swift — confirm → cooldown → quiz → success/fail
//

import SwiftUI

private enum UnlockPhase { case confirm, cooldown, quiz, success, fail }

struct UnlockFlowView: View {
    @Environment(AppState.self) private var app
    @Environment(\.fl) private var fl

    @State private var phase: UnlockPhase = {
        #if DEBUG
        switch UserDefaults.standard.string(forKey: "FL_PHASE")?.lowercased() {
        case "cooldown": return .cooldown
        case "quiz":     return .quiz
        case "success":  return .success
        case "fail":     return .fail
        default: return .confirm
        }
        #else
        return .confirm
        #endif
    }()
    @State private var cool: Int = 15
    @State private var deck: [Question] = QuestionBank().draw(
        subjects: Set(Subject.allCases),
        count: 5)
    @State private var qi: Int = 0
    @State private var correct: Int = 0
    @State private var picked: Int? = nil
    @State private var reveal: Bool = false

    @State private var cooldownTimer: Timer? = nil
    @State private var showEmergencyConfirm = false

    private var needCorrect: Int { app.unlockSettings.needCorrect }

    var body: some View {
        FLScreen {
            switch phase {
            case .confirm:  confirmView
            case .cooldown: cooldownView
            case .quiz:     quizView
            case .success:  successView
            case .fail:     failView
            }
        }
        .onAppear {
            deck = app.bank.draw(subjects: app.unlockSettings.subjects, count: max(needCorrect + 1, 3))
            if !app.unlockSettings.fictionEnabled { startCooldown() }
        }
        .onDisappear {
            cooldownTimer?.invalidate(); cooldownTimer = nil
        }
    }

    // ----- CONFIRM -----
    private var confirmView: some View {
        VStack(spacing: 0) {
            Spacer()
            Group {
                if app.mascotEnabled { Cat(size: 150, mood: .worry) }
                else { HeartLock(size: 92, color: fl.amber) }
            }
            .flWiggle()

            Text("真的要解鎖嗎?")
                .font(.system(size: 26, weight: .heavy))
                .padding(.top, 14)

            (Text("先深呼吸一下。確定要中斷專注的話,\n你得通過 ")
             + Text("\(needCorrect) 題").foregroundStyle(fl.primaryDeep).bold()
             + Text("考驗才能放行喔。"))
            .font(.system(size: 14.5))
            .foregroundStyle(fl.inkSoft)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .padding(.top, 12)
            .padding(.horizontal, 26)

            FLCard(cornerRadius: 20, smallShadow: true) {
                HStack(spacing: 10) {
                    LineIcon(name: .info, size: 20, color: fl.amber)
                    Text("科目範圍:\(app.unlockSettings.subjects.map(\.rawValue).joined(separator: "、"))・高一～高二")
                        .font(.system(size: 13))
                        .foregroundStyle(fl.inkSoft)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 18)
            }
            .padding(.top, 22)
            .padding(.horizontal, 26)

            Spacer()

            VStack(spacing: 10) {
                Button { startCooldown() } label: {
                    Text("我想清楚了,繼續解鎖")
                }
                .buttonStyle(FLCTAStyle(
                    gradient: LinearGradient(colors: [fl.amber, Color(hex: 0xD68A2E)],
                                             startPoint: .top, endPoint: .bottom),
                    shadowColor: Color(hex: 0xC97F26)
                ))

                Button { cancel() } label: {
                    Text("算了,我再撐一下 💪")
                        .font(.system(size: 15.5, weight: .heavy))
                        .foregroundStyle(fl.focus)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                }
                .buttonStyle(.plain)

                Button { showEmergencyConfirm = true } label: {
                    HStack(spacing: 4) {
                        LineIcon(name: .siren, size: 13, color: fl.inkFaint)
                        Text("緊急解鎖(會被記錄 · 已用 \(app.emergencyUnlockCount) 次)")
                    }
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(fl.inkFaint)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 26)
            .padding(.bottom, 36)
        }
        .alert("使用緊急解鎖?", isPresented: $showEmergencyConfirm) {
            Button("取消", role: .cancel) { }
            Button("確認解鎖", role: .destructive) { emergencyUnlock() }
        } message: {
            Text("會直接結束鎖定,並把這次紀錄到統計裡。\n建議只在真的有急事時使用。")
        }
    }

    // ----- COOLDOWN -----
    private var cooldownView: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack(spacing: 7) {
                LineIcon(name: .breath, size: 16, color: fl.focus)
                Text("冷靜一下")
                    .font(.system(size: 13.5, weight: .heavy))
                    .foregroundStyle(fl.inkSoft)
            }
            .padding(.horizontal, 16).padding(.vertical, 7)
            .background(Capsule().fill(fl.surface))
            .modifier(FLShadow.cardSmall(fl))

            ZStack {
                Circle().stroke(fl.surface3, lineWidth: 9)
                    .frame(width: 180, height: 180)
                Circle()
                    .trim(from: 0, to: cool > 0 ? CGFloat(15 - cool) / 15.0 : 1.0)
                    .stroke(fl.focus, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: cool)
                Text("\(cool)")
                    .font(.system(size: 56, weight: .heavy).monospacedDigit())
                    .foregroundStyle(fl.focus)
                    .flBreathe(duration: 4)
            }
            .padding(.vertical, 30)

            Text("慢慢吸氣…吐氣…")
                .font(.system(size: 23, weight: .heavy))
            Text("衝動通常只有幾秒鐘。\n等麻糬數完,你也許就不想滑手機了。")
                .font(.system(size: 14))
                .foregroundStyle(fl.inkSoft)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.top, 10)
                .padding(.horizontal, 30)

            if app.mascotEnabled {
                Cat(size: 92, mood: .sleep).padding(.top, 26).flFloat()
            } else {
                Volleyball(size: 72, spin: app.spinAnimationEnabled).padding(.top, 26).flFloat()
            }
            Spacer()
        }
    }

    // ----- QUIZ -----
    private var quizView: some View {
        let q = deck[qi]
        return ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Button { cancel() } label: {
                        LineIcon(name: .close, size: 18, color: fl.ink)
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(fl.surface))
                            .modifier(FLShadow.cardSmall(fl))
                    }.buttonStyle(.plain)

                    HStack(spacing: 6) {
                        ForEach(0..<deck.count, id: \.self) { i in
                            Capsule().fill(progressColor(i))
                                .frame(height: 7)
                        }
                    }

                    HStack(spacing: 4) {
                        LineIcon(name: .check, size: 14, color: fl.focus)
                        Text("\(correct)/\(needCorrect)")
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(fl.focus)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 5)
                    .background(Capsule().fill(fl.focusSoft))
                }
                .padding(.horizontal, 22)
                .padding(.top, 14)
                .padding(.bottom, 10)

                HStack(spacing: 9) {
                    SubjectIcon(subject: q.subject, size: 40)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("\(q.subject.rawValue)・\(q.topic)")
                            .font(.system(size: 15, weight: .heavy))
                        Text("\(q.grade)範圍")
                            .font(.system(size: 12))
                            .foregroundStyle(fl.inkSoft)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 14)

                FLCard(cornerRadius: 24) {
                    Text(q.question)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(fl.ink)
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 18)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 16)

                VStack(spacing: 10) {
                    ForEach(q.options.indices, id: \.self) { i in
                        optionRow(i, q: q)
                    }
                }
                .padding(.horizontal, 22)

                if reveal {
                    HStack(alignment: .top, spacing: 9) {
                        LineIcon(name: .info, size: 18, color: fl.primaryDeep)
                        Text(q.explanation)
                            .font(.system(size: 13.5))
                            .foregroundStyle(fl.inkSoft)
                            .lineSpacing(4)
                    }
                    .padding(13)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(fl.surface2))
                    .padding(.horizontal, 22)
                    .padding(.top, 14)
                    .transition(.opacity)
                }

                Color.clear.frame(height: 30)
            }
        }
    }

    private func progressColor(_ i: Int) -> Color {
        if i < qi { return fl.focus }
        if i == qi { return fl.primary }
        return fl.surface3
    }

    private func optionRow(_ i: Int, q: Question) -> some View {
        let isAns = i == q.answerIndex
        let isPicked = picked == i
        let bg: Color = (reveal && isAns) ? fl.focusSoft
                      : (reveal && isPicked && !isAns) ? fl.dangerSoft
                      : fl.surface
        let stroke: Color = (reveal && isAns) ? fl.focus
                          : (reveal && isPicked && !isAns) ? fl.danger
                          : fl.hairline
        let fg: Color = (reveal && isAns) ? fl.focus
                      : (reveal && isPicked && !isAns) ? fl.danger
                      : fl.ink
        return Button { choose(i, q: q) } label: {
            HStack(spacing: 13) {
                Text(["A","B","C","D"][i])
                    .font(.system(size: 13.5, weight: .heavy))
                    .foregroundStyle(fl.inkSoft)
                    .frame(width: 26, height: 26)
                    .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(fl.surface3))
                Text(q.options[i])
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(fg)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 4)
                if reveal && isAns {
                    LineIcon(name: .check, size: 20, color: fl.focus)
                } else if reveal && isPicked && !isAns {
                    LineIcon(name: .close, size: 20, color: fl.danger)
                }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous).fill(bg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(stroke, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(reveal)
    }

    // ----- SUCCESS -----
    private var successView: some View {
        VStack(spacing: 0) {
            ZStack {
                ForEach(0..<14, id: \.self) { i in
                    ConfettiPiece(index: i)
                        .fill([fl.primary, fl.blonde, fl.focus, fl.paw][i % 4])
                }
            }
            .frame(height: 0)
            Spacer()
            ZStack {
                Volleyball(size: 130, spin: app.spinAnimationEnabled)
                Sparkle(size: 26, color: fl.blonde)
                    .offset(x: 60, y: -50)
                Sparkle(size: 18, color: fl.primary)
                    .offset(x: -60, y: 40)
            }
            if app.mascotEnabled {
                Cat(size: 120, mood: .cheer).padding(.top, 6)
            }
            Text("漂亮扣球!")
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(fl.focus)
                .padding(.top, 10)
            Text("答對 \(correct) 題,結界解除。\n休息一下,等等記得回來找麻糬喔 🏐")
                .font(.system(size: 15))
                .foregroundStyle(fl.inkSoft)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.top, 10)
                .padding(.horizontal, 28)
            Spacer()
            Button { finish() } label: { Text("解鎖,使用 App") }
                .buttonStyle(FLCTAStyle(
                    gradient: LinearGradient(colors: [fl.focus, Color(hex: 0x4C9C75)],
                                             startPoint: .top, endPoint: .bottom),
                    shadowColor: Color(hex: 0x4C9C75)))
                .padding(.horizontal, 26)
                .padding(.bottom, 36)
        }
    }

    // ----- FAIL -----
    private var failView: some View {
        VStack(spacing: 0) {
            Spacer()
            Group {
                if app.mascotEnabled { Cat(size: 140, mood: .worry) }
                else { Volleyball(size: 110, spin: app.spinAnimationEnabled) }
            }
            Text("差一點點!")
                .font(.system(size: 25, weight: .heavy))
                .padding(.top, 12)
            Text("答對 \(correct)/\(needCorrect) 題,還沒達標。\n也許這是個訊號 —— 再專注一會兒吧?")
                .font(.system(size: 14.5))
                .foregroundStyle(fl.inkSoft)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.top, 12)
                .padding(.horizontal, 26)
            Spacer()
            VStack(spacing: 10) {
                Button { retry() } label: { Text("再挑戰一次") }
                    .buttonStyle(FLCTAStyle())
                Button { cancel() } label: {
                    Text("好,我繼續專注 💪")
                        .font(.system(size: 15.5, weight: .heavy))
                        .foregroundStyle(fl.focus)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 26)
            .padding(.bottom, 36)
        }
    }

    // ----- Actions -----
    private func startCooldown() {
        phase = .cooldown
        cool = max(1, app.unlockSettings.cooldownSeconds)
        cooldownTimer?.invalidate()
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if cool <= 1 {
                cooldownTimer?.invalidate(); cooldownTimer = nil
                phase = .quiz
            } else {
                cool -= 1
            }
        }
    }
    private func choose(_ i: Int, q: Question) {
        guard !reveal else { return }
        picked = i
        reveal = true
        let ok = (i == q.answerIndex)
        let newCorrect = correct + (ok ? 1 : 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + (ok ? 0.75 : 1.5)) {
            correct = newCorrect
            if ok && newCorrect >= needCorrect { phase = .success; return }
            if qi + 1 >= deck.count {
                phase = (newCorrect >= needCorrect) ? .success : .fail; return
            }
            qi += 1; picked = nil; reveal = false
        }
    }
    private func retry() {
        cool = max(1, app.unlockSettings.cooldownSeconds)
        qi = 0; correct = 0; picked = nil; reveal = false
        deck = app.bank.draw(subjects: app.unlockSettings.subjects, count: max(needCorrect + 1, 3))
        startCooldown()
    }
    private func finish() {
        app.lockSession.unlock(reason: .quizUnlocked)
        app.quizUnlockCount += 1
        Task { await ScreenTimeService.shared.stopShield() }
        app.route = .main
    }
    private func emergencyUnlock() {
        cooldownTimer?.invalidate(); cooldownTimer = nil
        app.emergencyUnlockCount += 1
        app.lockSession.unlock(reason: .emergency)
        Task { await ScreenTimeService.shared.stopShield() }
        app.route = .main
    }
    private func cancel() {
        cooldownTimer?.invalidate(); cooldownTimer = nil
        app.route = .main
    }
}

private struct ConfettiPiece: Shape {
    let index: Int
    func path(in rect: CGRect) -> Path {
        let x = (0.08 + Double(index) * 0.062) * 390
        let dy = 200 + Double(index % 4) * 80
        let r: CGFloat = 4.5
        return Path(ellipseIn: CGRect(x: x - r, y: dy - r, width: r * 2, height: r * 2))
    }
}
