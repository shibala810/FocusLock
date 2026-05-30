//
//  BlockScreen.swift — block-target catalog (also entry to FamilyActivityPicker)
//

import SwiftUI
import FamilyControls

struct BlockScreen: View {
    @Environment(AppState.self) private var app
    @Environment(\.fl) private var fl
    @State private var showPicker = false

    var body: some View {
        FLScreen {
            PawField()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    TopBar(title: "封鎖對象", sub: "已選擇 \(app.blockCount) 個 App",
                           onBack: { app.route = .main })

                    VStack(spacing: 18) {
                        // intro card
                        FLCard(cornerRadius: 22) {
                            HStack(spacing: 13) {
                                if app.mascotEnabled { Cat(size: 56, mood: .study) }
                                (Text("選出容易讓你分心的 App。鎖定時,這些會")
                                 + Text("暫時打不開").foregroundStyle(fl.primaryDeep).bold()
                                 + Text(",但電話、訊息不受影響喔。"))
                                .font(.system(size: 13.5))
                                .foregroundStyle(fl.inkSoft)
                                .lineSpacing(3)
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 18)
                        }

                        // open Apple picker
                        Button { showPicker = true } label: {
                            HStack(spacing: 8) {
                                LineIcon(name: .plus, size: 18, color: fl.onPrimary)
                                Text("用系統選擇 App(隱私版)")
                            }
                        }
                        .buttonStyle(FLCTAStyle())

                        // catalog (mock UI, not real picker — kept per design)
                        VStack(spacing: 18) {
                            ForEach(app.catalog.indices, id: \.self) { ci in
                                catalogCategory(ci)
                            }
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 6)
                    .padding(.bottom, 36)
                }
            }
        }
        .familyActivityPicker(isPresented: $showPicker,
                              selection: Binding(
                                get: { ScreenTimeService.shared.selection },
                                set: { newSel in
                                    ScreenTimeService.shared.selection = newSel
                                    ScreenTimeService.shared.persistSelection()
                                }))
    }

    @ViewBuilder
    private func catalogCategory(_ ci: Int) -> some View {
        let c = app.catalog[ci]
        let onCount = c.apps.filter(\.on).count
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 8) {
                Circle().fill(c.color).frame(width: 9, height: 9)
                Text(c.name).font(.system(size: 15, weight: .heavy))
                Text("\(onCount)/\(c.apps.count)")
                    .font(.system(size: 12.5, weight: .heavy))
                    .foregroundStyle(fl.inkFaint)
            }
            .padding(.horizontal, 6)
            FLCard(cornerRadius: 22) {
                VStack(spacing: 0) {
                    ForEach(c.apps.indices, id: \.self) { ai in
                        let a = c.apps[ai]
                        HStack(spacing: 13) {
                            Text(String(a.name.prefix(1)))
                                .font(.system(size: 18, weight: .heavy))
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(c.color))
                            Text(a.name)
                                .font(.system(size: 15.5, weight: .heavy))
                                .foregroundStyle(fl.ink)
                            Spacer()
                            FLToggle(isOn: Binding(
                                get: { a.on },
                                set: { newVal in
                                    app.catalog[ci].apps[ai].on = newVal
                                }
                            ), color: c.color)
                        }
                        .padding(.vertical, 11)
                        .padding(.horizontal, 16)
                        .overlay(alignment: .bottom) {
                            if ai != c.apps.count - 1 {
                                Rectangle().fill(fl.hairline).frame(height: 1)
                            }
                        }
                    }
                }
            }
        }
    }
}
