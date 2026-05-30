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

    private var timer: Timer?

    func lock(forMinutes minutes: Int) {
        let secs = max(1, minutes) * 60
        endsAt = Date().addingTimeInterval(TimeInterval(secs))
        remainingSeconds = secs
        state = .locked
        startTicker()
    }

    func unlock() {
        endsAt = nil
        remainingSeconds = 0
        state = .idle
        timer?.invalidate(); timer = nil
    }

    private func startTicker() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            guard let end = self.endsAt else { return }
            let left = max(0, Int(end.timeIntervalSinceNow.rounded()))
            self.remainingSeconds = left
            if left <= 0 { self.unlock() }
        }
    }

    static func fmt(_ totalSec: Int) -> String {
        let h = totalSec / 3600
        let m = (totalSec % 3600) / 60
        let s = totalSec % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
