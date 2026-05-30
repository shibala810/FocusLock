//
//  FocusLogStore.swift — append-only log of focus sessions
//
//  Stored in the shared app group so the DeviceActivityMonitor extension
//  can also write to it when scheduled intervals end.
//

import Foundation

@Observable
final class FocusLogStore {
    static let shared = FocusLogStore()

    private(set) var sessions: [FocusSession] = []
    private(set) var attempts: [QuizAttempt] = []

    private let key = "focusLog"
    private let attemptsKey = "quizAttempts"
    private var defaults: UserDefaults { SharedStorage.defaults }

    init() { load() }

    // MARK: - Mutation

    func append(_ s: FocusSession) {
        sessions.append(s)
        // Cap stored history to keep UserDefaults size reasonable.
        if sessions.count > 1000 { sessions.removeFirst(sessions.count - 1000) }
        persist()
    }

    func recordAttempt(_ a: QuizAttempt) {
        attempts.append(a)
        if attempts.count > 5000 { attempts.removeFirst(attempts.count - 5000) }
        persistAttempts()
    }

    func clear() {
        sessions.removeAll()
        attempts.removeAll()
        persist()
        persistAttempts()
    }

    // MARK: - Persistence

    private func load() {
        if let data = defaults.data(forKey: key),
           let arr = try? JSONDecoder().decode([FocusSession].self, from: data) {
            sessions = arr
        }
        if let data = defaults.data(forKey: attemptsKey),
           let arr = try? JSONDecoder().decode([QuizAttempt].self, from: data) {
            attempts = arr
        }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        defaults.set(data, forKey: key)
    }
    private func persistAttempts() {
        guard let data = try? JSONEncoder().encode(attempts) else { return }
        defaults.set(data, forKey: attemptsKey)
    }

    /// Subject mastery — correct / total across all logged attempts.
    /// Returns nil for a subject the user has never been tested on so the UI
    /// can render "—" instead of a misleading 0%.
    func mastery() -> [Subject: Double] {
        var total: [Subject: Int] = [:]
        var correct: [Subject: Int] = [:]
        for a in attempts {
            total[a.subject, default: 0] += 1
            if a.correct { correct[a.subject, default: 0] += 1 }
        }
        var result: [Subject: Double] = [:]
        for (subject, totalCount) in total where totalCount > 0 {
            result[subject] = Double(correct[subject] ?? 0) / Double(totalCount)
        }
        return result
    }
    func attemptCount(for subject: Subject) -> Int {
        attempts.filter { $0.subject == subject }.count
    }

    // MARK: - Queries

    private var calendar: Calendar { .current }

    /// Total focused minutes in the calendar day of `date`.
    func minutes(on date: Date) -> Int {
        let day = calendar.startOfDay(for: date)
        let next = calendar.date(byAdding: .day, value: 1, to: day) ?? day
        return sessions
            .filter { $0.startedAt >= day && $0.startedAt < next }
            .reduce(0) { $0 + $1.actualMinutes }
    }

    /// Minutes per day across the past 7 days, ending on `endingOn` (default = today),
    /// in chronological order (oldest first). Each tuple's `day` is a localized
    /// 一/二/三/… single-character label.
    func lastSevenDays(endingOn endDate: Date = Date()) -> [(day: String, minutes: Int)] {
        let labels = ["日", "一", "二", "三", "四", "五", "六"]
        let cal = calendar
        var out: [(String, Int)] = []
        for offset in (0..<7).reversed() {
            guard let d = cal.date(byAdding: .day, value: -offset, to: endDate) else { continue }
            let weekdayIndex = (cal.component(.weekday, from: d) - 1) % 7   // 1 = Sunday
            out.append((labels[weekdayIndex], minutes(on: d)))
        }
        return out
    }

    /// Number of consecutive days (counting backwards from today) where the
    /// user hit at least `threshold` focused minutes. Today's progress is
    /// included only if it already meets the threshold; otherwise the streak
    /// is computed from yesterday backwards.
    func streak(threshold: Int = 30, asOf date: Date = Date()) -> Int {
        let cal = calendar
        var d = cal.startOfDay(for: date)
        var count = 0
        if minutes(on: d) < threshold {
            // Don't penalize "haven't finished today yet" — start from yesterday.
            guard let y = cal.date(byAdding: .day, value: -1, to: d) else { return 0 }
            d = y
        }
        while minutes(on: d) >= threshold {
            count += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: d) else { break }
            d = prev
        }
        return count
    }

    #if DEBUG
    /// Wipe + populate the log with seven days of plausible sessions so
    /// Stats has something to render in screenshots. Triggered by the
    /// `-FL_SEED YES` launch arg.
    func seedDemo() {
        sessions.removeAll()
        let cal = Calendar.current
        let nowDay = cal.startOfDay(for: Date())
        let daysAndMinutes: [(daysAgo: Int, totalMin: Int, completed: Bool)] = [
            (6, 140, true),  (5, 95,  true),  (4, 175, true),
            (3, 210, true),  (2, 120, true),  (1, 190, true),
            (0, 165, true),
        ]
        for entry in daysAndMinutes {
            guard let dayStart = cal.date(byAdding: .day, value: -entry.daysAgo, to: nowDay) else { continue }
            // Split each day into one or two sessions to make the data feel real.
            let firstStart = cal.date(byAdding: .minute, value: 60 * 18, to: dayStart) ?? dayStart  // 6pm
            let mins = entry.totalMin
            let half = mins / 2
            let s1End   = firstStart.addingTimeInterval(TimeInterval(half * 60))
            let s2Start = s1End.addingTimeInterval(15 * 60)
            let s2End   = s2Start.addingTimeInterval(TimeInterval((mins - half) * 60))
            sessions.append(FocusSession(
                id: UUID().uuidString, startedAt: firstStart, endedAt: s1End,
                plannedMinutes: half, endReason: .completed, trigger: .instant))
            sessions.append(FocusSession(
                id: UUID().uuidString, startedAt: s2Start, endedAt: s2End,
                plannedMinutes: mins - half,
                endReason: entry.daysAgo == 1 ? .quizUnlocked : .completed,
                trigger: .scheduled))
        }
        persist()
    }
    #endif

    /// Today's "early unlock" attempts — quiz-passed + emergency. Used to
    /// enforce the daily limit configured in UnlockSettings.
    func earlyUnlocksToday(asOf date: Date = Date()) -> Int {
        let day = calendar.startOfDay(for: date)
        let next = calendar.date(byAdding: .day, value: 1, to: day) ?? day
        return sessions.filter {
            $0.startedAt >= day && $0.startedAt < next &&
            ($0.endReason == .quizUnlocked || $0.endReason == .emergency)
        }.count
    }

    var emergencyCount: Int  { sessions.filter { $0.endReason == .emergency    }.count }
    var quizUnlockCount: Int { sessions.filter { $0.endReason == .quizUnlocked }.count }
    var completedCount: Int  { sessions.filter { $0.endReason == .completed    }.count }

    /// Distinct days (across the whole log) where total minutes >= threshold —
    /// used as a stand-in for "distractions blocked" in the scoreboard hero.
    func successfulDays(threshold: Int = 30) -> Int {
        let cal = calendar
        let grouped = Dictionary(grouping: sessions) { cal.startOfDay(for: $0.startedAt) }
        return grouped.values.filter { day in day.reduce(0) { $0 + $1.actualMinutes } >= threshold }.count
    }
}
