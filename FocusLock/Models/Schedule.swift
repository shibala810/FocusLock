//
//  Schedule.swift
//

import Foundation

struct Schedule: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var startHour: Int   // 0..23
    var startMinute: Int // 0..59
    var endHour: Int
    var endMinute: Int
    var days: Set<Int>   // 0 = 日, 1 = 一, ..., 6 = 六
    var enabled: Bool
    var friction: Bool

    var startTimeString: String { String(format: "%02d:%02d", startHour, startMinute) }
    var endTimeString:   String { String(format: "%02d:%02d", endHour, endMinute) }

    init(id: String = UUID().uuidString,
         name: String,
         start: String,
         end: String,
         days: Set<Int>,
         enabled: Bool,
         friction: Bool) {
        self.id = id
        self.name = name
        let s = Self.parseTime(start)
        let e = Self.parseTime(end)
        self.startHour = s.h; self.startMinute = s.m
        self.endHour = e.h;   self.endMinute = e.m
        self.days = days
        self.enabled = enabled
        self.friction = friction
    }

    private static func parseTime(_ s: String) -> (h: Int, m: Int) {
        let parts = s.split(separator: ":").compactMap { Int($0) }
        let h = parts.first ?? 0, m = (parts.count > 1 ? parts[1] : 0)
        return (max(0, min(23, h)), max(0, min(59, m)))
    }
}

extension Schedule {
    static let samples: [Schedule] = [
        Schedule(id: "s1", name: "晚自習",       start: "19:00", end: "22:00",
                 days: [1,2,3,4,5], enabled: true,  friction: true),
        Schedule(id: "s2", name: "睡前淨化",     start: "23:00", end: "06:30",
                 days: [0,1,2,3,4,5,6], enabled: true,  friction: false),
        Schedule(id: "s3", name: "週末讀書會",   start: "14:00", end: "17:00",
                 days: [0,6], enabled: false, friction: true),
    ]
}

let WEEK_LABELS = ["日", "一", "二", "三", "四", "五", "六"]
