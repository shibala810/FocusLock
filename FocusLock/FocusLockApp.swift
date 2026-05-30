//
//  FocusLockApp.swift
//  FocusLock
//

import SwiftUI

@main
struct FocusLockApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .preferredColorScheme(appState.theme.colorScheme)
        }
    }
}
