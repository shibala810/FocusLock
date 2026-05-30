//
//  NotificationService.swift — schedule local reminders before each enabled schedule starts
//

import Foundation
import UserNotifications

@MainActor
@Observable
final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    var isAuthorized = false

    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
        } catch {
            isAuthorized = false
        }
    }

    /// Re-build all notifications based on current schedules + settings.
    /// Idempotent: safe to call on every schedule change.
    func rebuild(schedules: [Schedule], leadMinutes: Int, enabled: Bool) async {
        let center = UNUserNotificationCenter.current()
        // Always wipe our own first so the set reflects current state.
        let existing = await center.pendingNotificationRequests()
        let ourIds = existing.filter { $0.identifier.hasPrefix("fl_sched_") }.map(\.identifier)
        center.removePendingNotificationRequests(withIdentifiers: ourIds)

        guard enabled, isAuthorized else { return }

        for s in schedules where s.enabled {
            for day in s.days.sorted() {
                let when = leadTime(hour: s.startHour, minute: s.startMinute, leadMinutes: leadMinutes)
                let content = UNMutableNotificationContent()
                content.title = "專注結界即將開始"
                content.body  = "「\(s.name.isEmpty ? "排程" : s.name)」\(leadMinutes) 分鐘後啟動,先把該收的東西收一收喵 🐾"
                content.sound = .default

                var dc = DateComponents()
                dc.weekday = day + 1   // UNCalendar: 1 = Sunday
                dc.hour = when.h
                dc.minute = when.m

                let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
                let req = UNNotificationRequest(
                    identifier: "fl_sched_\(s.id)_\(day)",
                    content: content, trigger: trigger)
                try? await center.add(req)
            }
        }
    }

    private func leadTime(hour: Int, minute: Int, leadMinutes: Int) -> (h: Int, m: Int) {
        var total = hour * 60 + minute - leadMinutes
        if total < 0 { total += 24 * 60 }
        return (total / 60, total % 60)
    }
}
