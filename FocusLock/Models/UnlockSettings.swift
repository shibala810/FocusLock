//
//  UnlockSettings.swift
//

import Foundation

struct UnlockSettings: Codable, Equatable {
    var needCorrect: Int = 2          // 1..5
    var cooldownSeconds: Int = 15     // 0..15 min in real spec; we use seconds for snappier demo
    var dailyLimit: Int = 3
    var subjects: Set<Subject> = Set(Subject.allCases)
    var fictionEnabled: Bool = true   // alias of friction; misspell preserved? No — fix:
}

extension UnlockSettings {
    static let `default` = UnlockSettings()
}
