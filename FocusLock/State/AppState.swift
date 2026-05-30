//
//  AppState.swift
//

import SwiftUI

enum AppRoute: Hashable { case welcome, main, block, editSchedule, unlock }
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
    var route: AppRoute = .welcome
    var tab: MainTab = .home

    let lockSession = LockSession()
    let bank = QuestionBank()

    var schedules: [Schedule] {
        didSet { persistSchedules() }
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
    var editingSchedule: Schedule? = nil
    var catalog: [CatalogCategory]

    // Stats — light-weight in-memory snapshot for v1
    var todayFocusMinutes: Int = 165
    var streak: Int = 12
    var weekFocus: [(day: String, minutes: Int)] = [
        ("一", 165), ("二", 190), ("三", 120), ("四", 210),
        ("五", 175), ("六",  95), ("日", 140),
    ]

    init() {
        // load persisted bits
        let d = UserDefaults.standard
        if let raw = d.string(forKey: "theme"), let t = AppTheme(rawValue: raw) {
            self.theme = t
        } else {
            self.theme = .system
        }
        self.mascotEnabled = d.object(forKey: "mascot") as? Bool ?? true
        self.spinAnimationEnabled = d.object(forKey: "spin") as? Bool ?? true

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
