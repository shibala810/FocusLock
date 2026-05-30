//
//  ScreenTimeService.swift — FamilyControls + ManagedSettings wrapper
//

import Foundation
import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity

@MainActor
@Observable
final class ScreenTimeService {
    static let shared = ScreenTimeService()
    private init() { loadSelection() }

    var isAuthorized: Bool = false
    var selection = FamilyActivitySelection()
    /// Shared between main app and the DeviceActivityMonitor extension
    /// via the same identifier so the extension can read what we set.
    private let store = ManagedSettingsStore(named: .init("FocusLockShield"))
    private let selectionKey = SharedStorage.Key.famSelection

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

    // MARK: Schedule monitoring (DeviceActivity)

    private let activityCenter = DeviceActivityCenter()

    /// Re-register all `DeviceActivitySchedule`s based on the current
    /// `[Schedule]`. Idempotent: stops everything we previously monitored
    /// (anything with the `fl_` prefix) and re-creates active ones.
    func reconcileSchedules(_ schedules: [Schedule]) async {
        // Stop everything we own first.
        let activeNames = activityCenter.activities.filter { $0.rawValue.hasPrefix("fl_") }
        if !activeNames.isEmpty {
            activityCenter.stopMonitoring(Array(activeNames))
        }

        for s in schedules where s.enabled {
            for day in s.days.sorted() {
                let weekday = day + 1   // DeviceActivity: 1 = Sunday
                let windows = scheduleWindows(start: (s.startHour, s.startMinute),
                                              end: (s.endHour, s.endMinute),
                                              weekday: weekday)
                for (idx, win) in windows.enumerated() {
                    let activity = DeviceActivityName("fl_\(s.id)_\(day)_\(idx)")
                    let activitySchedule = DeviceActivitySchedule(
                        intervalStart: win.start,
                        intervalEnd: win.end,
                        repeats: true)
                    do {
                        try activityCenter.startMonitoring(activity, during: activitySchedule)
                    } catch {
                        // Log and continue — one broken schedule shouldn't kill the rest.
                        print("DeviceActivity startMonitoring failed for \(activity.rawValue): \(error)")
                    }
                }
            }
        }
    }

    /// Most schedules fit in one day. If a schedule wraps past midnight
    /// (e.g. 23:00 → 06:30 sleep), split it into two windows: tonight until
    /// 23:59, and tomorrow 00:00 until 06:30 — DeviceActivitySchedule
    /// requires start < end within the same recurrence cycle.
    private func scheduleWindows(start: (h: Int, m: Int),
                                 end:   (h: Int, m: Int),
                                 weekday: Int) -> [(start: DateComponents, end: DateComponents)] {
        let startMin = start.h * 60 + start.m
        let endMin   = end.h   * 60 + end.m

        if endMin > startMin {
            var s = DateComponents(); s.weekday = weekday; s.hour = start.h; s.minute = start.m
            var e = DateComponents(); e.weekday = weekday; e.hour = end.h;   e.minute = end.m
            return [(s, e)]
        }

        // Wraps midnight: split into two windows.
        let nextWeekday = (weekday % 7) + 1   // 7 → 1
        var s1 = DateComponents(); s1.weekday = weekday; s1.hour = start.h; s1.minute = start.m
        var e1 = DateComponents(); e1.weekday = weekday; e1.hour = 23;      e1.minute = 59
        var s2 = DateComponents(); s2.weekday = nextWeekday; s2.hour = 0;   s2.minute = 0
        var e2 = DateComponents(); e2.weekday = nextWeekday; e2.hour = end.h; e2.minute = end.m
        return [(s1, e1), (s2, e2)]
    }

    // MARK: Selection persistence

    func persistSelection() {
        if let data = try? PropertyListEncoder().encode(selection) {
            SharedStorage.defaults.set(data, forKey: selectionKey)
        }
    }

    private func loadSelection() {
        if let data = SharedStorage.defaults.data(forKey: selectionKey),
           let s = try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data) {
            selection = s
        }
    }
}
