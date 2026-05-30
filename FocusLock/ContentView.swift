//
//  ContentView.swift  (RootView)
//  FocusLock
//

import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        ZStack {
            switch app.route {
            case .welcome:
                WelcomeScreen()
                    .transition(.opacity)
            case .main:
                MainTabs()
                    .transition(.opacity)
            case .block:
                BlockScreen()
                    .transition(.move(edge: .trailing))
            case .editSchedule:
                ScheduleEditorView()
                    .transition(.move(edge: .trailing))
            case .unlock:
                UnlockFlowView()
                    .transition(.opacity)
            case .questionBank:
                QuestionBankScreen()
                    .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.28), value: app.route)
        .flTheme()
    }
}

struct MainTabs: View {
    @Environment(AppState.self) private var app

    var body: some View {
        ZStack(alignment: .bottom) {
            // current screen
            Group {
                switch app.tab {
                case .home:     HomeScreen()
                case .schedule: ScheduleScreen()
                case .stats:    StatsScreen()
                case .settings: SettingsScreen()
                }
            }
            .id(app.tab)
            .transition(.opacity)

            if !(app.tab == .home && app.lockSession.state == .locked) {
                TabBar()
            }
        }
        .animation(.easeInOut(duration: 0.22), value: app.tab)
    }
}

// Keep ContentView around as a thin alias for backward-compat with Xcode previews.
struct ContentView: View {
    var body: some View { RootView() }
}

#Preview {
    RootView().environment(AppState.preview)
}
