//
//  FocusLockMonitorExtension.swift
//  FocusLockMonitor
//
//  DeviceActivityMonitor extension — runs in a separate process triggered
//  by DeviceActivityCenter when a registered DeviceActivitySchedule's
//  interval starts/ends. Sets/clears the same ManagedSettingsStore as the
//  main app so the configured shield applications are blocked during the
//  scheduled window.
//

import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings

// Shared with the main app — keep the values in sync with
// FocusLock/Services/SharedStorage.swift.
private enum Shared {
    static let appGroup = "group.com.shibala810.FocusLock"
    static let storeName = ManagedSettingsStore.Name("FocusLockShield")
    static let famSelectionKey = "famSelection"
    static let activeShieldKey = "activeShield"
}

class FocusLockMonitorExtension: DeviceActivityMonitor {

    private let store = ManagedSettingsStore(named: Shared.storeName)
    private var defaults: UserDefaults { UserDefaults(suiteName: Shared.appGroup) ?? .standard }

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        applyShieldFromSelection()
        defaults.set(true, forKey: Shared.activeShieldKey)
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        store.shield.applications = nil
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.none
        defaults.set(false, forKey: Shared.activeShieldKey)
    }

    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
    }

    private func applyShieldFromSelection() {
        guard let data = defaults.data(forKey: Shared.famSelectionKey),
              let selection = try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
        else { return }
        let apps = selection.applicationTokens
        let cats = selection.categoryTokens
        store.shield.applications = apps.isEmpty ? nil : apps
        store.shield.applicationCategories = cats.isEmpty
            ? ShieldSettings.ActivityCategoryPolicy.none
            : .specific(cats)
    }
}
