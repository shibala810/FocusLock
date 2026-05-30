//
//  ScreenTimeService.swift — FamilyControls + ManagedSettings wrapper
//

import Foundation
import SwiftUI
import FamilyControls
import ManagedSettings

@MainActor
@Observable
final class ScreenTimeService {
    static let shared = ScreenTimeService()
    private init() { loadSelection() }

    var isAuthorized: Bool = false
    var selection = FamilyActivitySelection()
    private let store = ManagedSettingsStore(named: .init("FocusLockShield"))
    private let selectionKey = "famSelection"

    // MARK: Authorization

    func requestAuthorization() async {
        #if targetEnvironment(simulator)
        // Simulator can't actually grant; mock-approve so flow continues.
        isAuthorized = true
        #else
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        } catch {
            isAuthorized = false
        }
        #endif
    }

    // MARK: Shield

    func startShield() async {
        let apps = selection.applicationTokens
        let cats = selection.categoryTokens
        store.shield.applications = apps.isEmpty ? nil : apps
        store.shield.applicationCategories = cats.isEmpty
            ? ShieldSettings.ActivityCategoryPolicy.none
            : .specific(cats)
    }

    func stopShield() async {
        store.shield.applications = nil
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.none
    }

    // MARK: Selection persistence

    func persistSelection() {
        if let data = try? PropertyListEncoder().encode(selection) {
            UserDefaults.standard.set(data, forKey: selectionKey)
        }
    }

    private func loadSelection() {
        if let data = UserDefaults.standard.data(forKey: selectionKey),
           let s = try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data) {
            selection = s
        }
    }
}
