//
//  LockSession.swift
//

import SwiftUI

@Observable
final class LockSession {
    enum State { case idle, locked }

    private(set) var state: State = .idle
    private(set) var endsAt: Date? = nil
    private(set) var remainingSeconds: Int = 0

    /// Snapshot of the lock currently in progress, for logging when it ends.
    private(set) var startedAt: Date? = nil
    private(set) var plannedMinutes: Int = 0
    private(set) var trigger: FocusTrigger = .instant

    private var timer: Timer?

    func lock(forMinutes minutes: Int, trigger: FocusTrigger = .instant) {
        let secs = max(1, minutes) * 60
        endsAt = Date().addingTimeInterval(TimeInterval(secs))
        remainingSeconds = secs
        startedAt = Date()
        plannedMinutes = minutes
        self.trigger = trigger
        state = .locked
        startTicker()
    }

    func unlock(reason: FocusEndReason) {
        // Record the session before clearing state.
        if let started = startedAt {
            FocusLogStore.shared.append(FocusSession(
                id: UUID().uuidString,
                startedAt: started,
                endedAt: Date(),
                plannedMinutes: plannedMinutes,
                endReason: reason,
                trigger: trigger))
        }
        endsAt = nil
        remainingSeconds = 0
        startedAt = nil
        plannedMinutes = 0
        state = .idle
        timer?.invalidate(); timer = nil
        // Lift the system-level shield for every unlock path (timer completion,
        // quiz, emergency) so the locked apps actually reopen.
        Task { @MainActor in await ScreenTimeService.shared.stopShield() }
    }

    private func startTicker() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            guard let end = self.endsAt else { return }
            let left = max(0, Int(end.timeIntervalSinceNow.rounded()))
            self.remainingSeconds = left
            if left <= 0 { self.unlock(reason: .completed) }
        }
    }

    static func fmt(_ totalSec: Int) -> String {
        let h = totalSec / 3600
        let m = (totalSec % 3600) / 60
        let s = totalSec % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
