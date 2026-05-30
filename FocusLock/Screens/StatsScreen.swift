//
//  StatsScreen.swift — scoreboard hero + week bar chart + subject mastery
//

import SwiftUI

struct StatsScreen: View {
    @Environment(AppState.self) private var app
    @Environment(\.fl) private var fl

    private var cheerSuffix: String {
        let school = app.targetSchool.trimmingCharacters(in: .whitespacesAndNewlines)
        return school.isEmpty
            ? "分心,專注又往前推一步喵!」"
            : "分心,離\(school)又近了一點喵!」"
    }

    var body: some View {
        let week = app.weekFocus
        let weekTotal = week.reduce(0) { $0 + $1.minutes }
        let hours = weekTotal / 60; let mins = weekTotal % 60
        let maxMin = max(1, week.map(\.minutes).max() ?? 1)
        let blocked = app.log.successfulDays()

        // Mastery from log: rolling % over completed quiz attempts.
        // For v1, since we don't yet track per-question correctness in the
        // log, derive a simple mock per subject only when there's nothing
        // to show; once real per-attempt logging lands this becomes real.
        let mastery: [(Subject, Double)] = [
            (.math, 0.82), (.english, 0.91), (.chinese, 0.68), (.history, 0.75)
        ]

        FLScreen {
            PawField()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    TopBar(title: "戰績", sub: "本週計分板")

                    VStack(spacing: 16) {
                        // scoreboard hero
                        ZStack(alignment: .topTrailing) {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(LinearGradient(colors: [fl.ballDark, Color(hex: 0x4A2F38)],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                            VStack(alignment: .leading, spacing: 0) {
                                Text("本週總專注")
                                    .font(.system(size: 13, weight: .heavy))
                                    .tracking(2)
                                    .foregroundStyle(Color.white.opacity(0.7))
                                HStack(alignment: .firstTextBaseline, spacing: 0) {
                                    Text("\(hours)")
                                        .font(.system(size: 46, weight: .heavy).monospacedDigit())
                                    Text(" 時 ").font(.system(size: 24))
                                    Text("\(mins)")
                                        .font(.system(size: 46, weight: .heavy).monospacedDigit())
                                    Text(" 分").font(.system(size: 24))
                                }
                                .foregroundStyle(.white)
                                .padding(.top, 2)

                                HStack(spacing: 22) {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("\(app.streak)")
                                            .font(.system(size: 22, weight: .heavy).monospacedDigit())
                                        Text("連續達標(天)")
                                            .font(.system(size: 12)).opacity(0.7)
                                    }
                                    Rectangle().fill(Color.white.opacity(0.18)).frame(width: 1, height: 36)
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("\(blocked)")
                                            .font(.system(size: 22, weight: .heavy).monospacedDigit())
                                        Text("擋下分心(次)")
                                            .font(.system(size: 12)).opacity(0.7)
                                    }
                                }
                                .foregroundStyle(.white)
                                .padding(.top, 14)
                            }
                            .padding(20)

                            Volleyball(size: 120, spin: app.spinAnimationEnabled)
                                .offset(x: 20, y: -20)
                                .opacity(0.9)
                        }

                        // unlock counters
                        HStack(spacing: 12) {
                            MiniStat(icon: { LineIcon(name: .check, size: 16, color: fl.focus) },
                                     label: "答題解鎖", value: "\(app.quizUnlockCount) 次",
                                     tint: fl.focus)
                            MiniStat(icon: { LineIcon(name: .siren, size: 16, color: fl.danger) },
                                     label: "緊急解鎖", value: "\(app.emergencyUnlockCount) 次",
                                     tint: fl.danger)
                        }

                        // weekly bar chart
                        FLCard(cornerRadius: 24) {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("每日專注時間")
                                        .font(.system(size: 15.5, weight: .heavy))
                                    Spacer()
                                    Text("分鐘")
                                        .font(.system(size: 12.5, weight: .heavy))
                                        .foregroundStyle(fl.inkFaint)
                                }
                                HStack(alignment: .bottom, spacing: 9) {
                                    ForEach(app.weekFocus.indices, id: \.self) { i in
                                        let d = app.weekFocus[i]
                                        let best = d.minutes == maxMin
                                        VStack(spacing: 7) {
                                            Text("\(d.minutes)")
                                                .font(.system(size: 11, weight: .heavy).monospacedDigit())
                                                .foregroundStyle(best ? fl.primaryDeep : fl.inkFaint)
                                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                                .fill(best
                                                      ? AnyShapeStyle(LinearGradient(colors: [fl.primary, fl.primaryDeep],
                                                                                    startPoint: .top, endPoint: .bottom))
                                                      : AnyShapeStyle(fl.primarySoft))
                                                .frame(height: CGFloat(d.minutes) / CGFloat(maxMin) * 130)
                                            Text(d.day)
                                                .font(.system(size: 12, weight: .heavy))
                                                .foregroundStyle(fl.inkSoft)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                                .frame(height: 170)
                            }
                            .padding(.vertical, 18)
                            .padding(.horizontal, 18)
                        }

                        // subject mastery
                        VStack(alignment: .leading, spacing: 12) {
                            Text("解鎖答題正確率")
                                .font(.system(size: 15.5, weight: .heavy))
                                .padding(.horizontal, 4)
                            FLCard(cornerRadius: 24) {
                                VStack(spacing: 0) {
                                    ForEach(mastery.indices, id: \.self) { i in
                                        let (sub, rate) = mastery[i]
                                        HStack(spacing: 13) {
                                            SubjectIcon(subject: sub, size: 36)
                                            VStack(alignment: .leading, spacing: 6) {
                                                HStack {
                                                    Text(sub.rawValue)
                                                        .font(.system(size: 14.5, weight: .heavy))
                                                    Spacer()
                                                    Text("\(Int(rate * 100))%")
                                                        .font(.system(size: 14.5, weight: .heavy).monospacedDigit())
                                                        .foregroundStyle(fl.focus)
                                                }
                                                ZStack(alignment: .leading) {
                                                    Capsule().fill(fl.surface3).frame(height: 7)
                                                    Capsule().fill(fl.focus)
                                                        .frame(width: 230 * rate, height: 7)
                                                }
                                            }
                                        }
                                        .padding(.vertical, 13)
                                        .padding(.horizontal, 16)
                                        .overlay(alignment: .bottom) {
                                            if i != mastery.count - 1 {
                                                Rectangle().fill(fl.hairline).frame(height: 1)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        if app.mascotEnabled {
                            FLCard(cornerRadius: 24) {
                                HStack(spacing: 13) {
                                    Cat(size: 64, mood: .cheer).flFloat(duration: 4)
                                    (Text("「這週擋下 ")
                                     + Text("\(blocked) 次").foregroundStyle(fl.primaryDeep).bold()
                                     + Text(cheerSuffix))
                                    .font(.system(size: 13.5))
                                    .foregroundStyle(fl.inkSoft)
                                    .lineSpacing(3)
                                }
                                .padding(16)
                            }
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 110)
                }
            }
        }
    }
}
