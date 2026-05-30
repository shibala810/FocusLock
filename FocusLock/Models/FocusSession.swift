//
//  FocusSession.swift
//

import Foundation

enum FocusEndReason: String, Codable {
    case completed       // lock ran to 0
    case quizUnlocked    // user passed the quiz to unlock early
    case emergency       // user used emergency unlock
}

enum FocusTrigger: String, Codable {
    case instant         // user pressed "立即鎖定"
    case scheduled       // DeviceActivitySchedule fired
}

struct FocusSession: Codable, Identifiable, Hashable {
    var id: String
    var startedAt: Date
    var endedAt: Date
    var plannedMinutes: Int
    var endReason: FocusEndReason
    var trigger: FocusTrigger

    /// Real elapsed minutes, capped at planned (we don't credit going over).
    var actualMinutes: Int {
        let raw = max(0, endedAt.timeIntervalSince(startedAt)) / 60
        return min(plannedMinutes, Int(raw.rounded()))
    }
}
