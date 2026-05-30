//
//  AppState.swift
//

import SwiftUI

enum AppRoute: Hashable { case welcome, main, block, editSchedule, unlock, questionBank }
enum MainTab: Hashable, CaseIterable { case home, schedule, stats, settings }

enum AppTheme: String, CaseIterable, Codable {
    case system, light, dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

@Observable
final class AppState {
    #if DEBUG
    var route: AppRoute = UserDefaults.standard.string(forKey: "FL_ROUTE").flatMap(routeFromString) ?? .welcome
    var tab: MainTab = UserDefaults.standard.string(forKey: "FL_TAB").flatMap(tabFromString) ?? .home
    #else
    var route: AppRoute = .welcome
    var tab: MainTab = .home
    #endif

    let lockSession = LockSession()
    let bank = QuestionBank()

    var schedules: [Schedule] {
        didSet { persistSchedules(); rebuildNotifications(); reconcileDeviceActivity() }
    }
    var unlockSettings: UnlockSettings {
        didSet { persistSettings() }
    }
    var theme: AppTheme {
        didSet { UserDefaults.standard.set(theme.rawValue, forKey: "theme") }
    }
    var mascotEnabled: Bool {
        didSet { UserDefaults.standard.set(mascotEnabled, forKey: "mascot") }
    }
    var spinAnimationEnabled: Bool {
        didSet { UserDefaults.standard.set(spinAnimationEnabled, forKey: "spin") }
    }
    var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notifs")
            rebuildNotifications()
        }
    }
    var notifyMinutesBefore: Int {
        didSet {
            UserDefaults.standard.set(notifyMinutesBefore, forKey: "notifsLead")
            rebuildNotifications()
        }
    }
    var emergencyUnlockCount: Int {
        didSet { UserDefaults.standard.set(emergencyUnlockCount, forKey: "emergencyCount") }
    }
    var quizUnlockCount: Int {
        didSet { UserDefaults.standard.set(quizUnlockCount, forKey: "quizUnlockCount") }
    }
    var userName: String {
        didSet { UserDefaults.standard.set(userName, forKey: "userName") }
    }
    var targetSchool: String {
        didSet { UserDefaults.standard.set(targetSchool, forKey: "targetSchool") }
    }
    /// Target exam date. `nil` hides the countdown row.
    var examDate: Date? {
        didSet {
            if let d = examDate {
                UserDefaults.standard.set(d, forKey: "examDate")
            } else {
                UserDefaults.standard.removeObject(forKey: "examDate")
            }
        }
    }
    /// Days from today until examDate. Returns nil if no date set, 0 if in the past.
    var daysUntilExam: Int? {
        guard let exam = examDate else { return nil }
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let target = cal.startOfDay(for: exam)
        let comps = cal.dateComponents([.day], from: today, to: target)
        return max(0, comps.day ?? 0)
    }
    var editingSchedule: Schedule? = nil
    var catalog: [CatalogCategory]
    let log = FocusLogStore.shared

    // Stats — derived from FocusLogStore.
    var todayFocusMinutes: Int { log.minutes(on: Date()) }
    var streak: Int { log.streak() }
    var weekFocus: [(day: String, minutes: Int)] { log.lastSevenDays() }

    init() {
        #if DEBUG
        if UserDefaults.standard.bool(forKey: "FL_SEED") {
            FocusLogStore.shared.seedDemo()
        }
        if UserDefaults.standard.bool(forKey: "FL_WIPE") {
            FocusLogStore.shared.clear()
        }
        let lockArg = UserDefaults.standard.integer(forKey: "FL_LOCK_MINUTES")
        #endif
        // load persisted bits
        let d = UserDefaults.standard
        if let raw = d.string(forKey: "theme"), let t = AppTheme(rawValue: raw) {
            self.theme = t
        } else {
            self.theme = .system
        }
        self.mascotEnabled = d.object(forKey: "mascot") as? Bool ?? true
        self.spinAnimationEnabled = d.object(forKey: "spin") as? Bool ?? true
        self.notificationsEnabled = d.object(forKey: "notifs") as? Bool ?? true
        self.notifyMinutesBefore = d.object(forKey: "notifsLead") as? Int ?? 5
        self.emergencyUnlockCount = d.integer(forKey: "emergencyCount")
        self.quizUnlockCount = d.integer(forKey: "quizUnlockCount")
        self.userName = d.string(forKey: "userName") ?? "考生"
        self.targetSchool = d.string(forKey: "targetSchool") ?? "理想大學"
        self.examDate = d.object(forKey: "examDate") as? Date

        if let data = d.data(forKey: "schedules"),
           let arr = try? JSONDecoder().decode([Schedule].self, from: data) {
            self.schedules = arr
        } else {
            self.schedules = Schedule.samples
        }
        if let data = d.data(forKey: "unlockSettings"),
           let s = try? JSONDecoder().decode(UnlockSettings.self, from: data) {
            self.unlockSettings = s
        } else {
            self.unlockSettings = .default
        }
        self.catalog = CatalogCategory.samples

        #if DEBUG
        if lockArg > 0 {
            lockSession.lock(forMinutes: lockArg)
        }
        #endif
    }

    var blockCount: Int {
        catalog.reduce(0) { $0 + $1.apps.filter(\.on).count }
    }
    var categoryCount: Int {
        catalog.filter { $0.apps.contains(where: \.on) }.count
    }

    private func persistSchedules() {
        if let data = try? JSONEncoder().encode(schedules) {
            UserDefaults.standard.set(data, forKey: "schedules")
        }
    }
    private func rebuildNotifications() {
        let snap = schedules
        let lead = notifyMinutesBefore
        let on = notificationsEnabled
        Task { await NotificationService.shared.rebuild(schedules: snap, leadMinutes: lead, enabled: on) }
    }
    private func reconcileDeviceActivity() {
        let snap = schedules
        Task { await ScreenTimeService.shared.reconcileSchedules(snap) }
    }
    private func persistSettings() {
        if let data = try? JSONEncoder().encode(unlockSettings) {
            UserDefaults.standard.set(data, forKey: "unlockSettings")
        }
    }

    // ---------- Test/preview helpers ----------
    static var preview: AppState {
        let s = AppState()
        s.route = .main
        return s
    }
}

#if DEBUG
private func routeFromString(_ s: String) -> AppRoute? {
    switch s.lowercased() {
    case "welcome": return .welcome
    case "main": return .main
    case "block": return .block
    case "editschedule": return .editSchedule
    case "unlock": return .unlock
    case "questionbank": return .questionBank
    default: return nil
    }
}
private func tabFromString(_ s: String) -> MainTab? {
    switch s.lowercased() {
    case "home": return .home
    case "schedule": return .schedule
    case "stats": return .stats
    case "settings": return .settings
    default: return nil
    }
}
#endif
