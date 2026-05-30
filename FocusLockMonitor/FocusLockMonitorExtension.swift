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
// FocusLock/Services/SharedStorage.swift and FocusLogStore.swift.
private enum Shared {
    static let appGroup = "group.com.shibala810.FocusLock"
    static let storeName = ManagedSettingsStore.Name("FocusLockShield")
    static let famSelectionKey = "famSelection"
    static let activeShieldKey = "activeShield"
    static let focusLogKey = "focusLog"
    static let sessionStartKeyPrefix = "schedStart_"
}

// Mirror of the main app's models, kept simple and Codable-only so this
// extension doesn't have to import the full app module.
private enum FocusEndReason: String, Codable { case completed, quizUnlocked, emergency }
private enum FocusTrigger:   String, Codable { case instant, scheduled }
private struct FocusSession: Codable {
    var id: String
    var startedAt: Date
    var endedAt: Date
    var plannedMinutes: Int
    var endReason: FocusEndReason
    var trigger: FocusTrigger
}

class FocusLockMonitorExtension: DeviceActivityMonitor {

    private let store = ManagedSettingsStore(named: Shared.storeName)
    private var defaults: UserDefaults { UserDefaults(suiteName: Shared.appGroup) ?? .standard }

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        applyShieldFromSelection()
        defaults.set(true, forKey: Shared.activeShieldKey)
        defaults.set(Date(), forKey: Shared.sessionStartKeyPrefix + activity.rawValue)
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        store.shield.applications = nil
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.none
        defaults.set(false, forKey: Shared.activeShieldKey)
        logSession(for: activity)
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

    private func logSession(for activity: DeviceActivityName) {
        let key = Shared.sessionStartKeyPrefix + activity.rawValue
        guard let started = defaults.object(forKey: key) as? Date else { return }
        defaults.removeObject(forKey: key)
        let ended = Date()
        let minutes = max(1, Int(ended.timeIntervalSince(started) / 60))
        let session = FocusSession(
            id: UUID().uuidString,
            startedAt: started,
            endedAt: ended,
            plannedMinutes: minutes,
            endReason: .completed,
            trigger: .scheduled)

        var log: [FocusSession] = []
        if let data = defaults.data(forKey: Shared.focusLogKey),
           let arr = try? JSONDecoder().decode([FocusSession].self, from: data) {
            log = arr
        }
        log.append(session)
        if log.count > 1000 { log.removeFirst(log.count - 1000) }
        if let data = try? JSONEncoder().encode(log) {
            defaults.set(data, forKey: Shared.focusLogKey)
        }
    }
}
