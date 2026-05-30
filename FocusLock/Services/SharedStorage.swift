//
//  SharedStorage.swift — App Group shared UserDefaults
//

import Foundation

enum SharedStorage {
    static let appGroup = "group.com.shibala810.FocusLock"

    /// UserDefaults backed by the app group container. Falls back to `.standard`
    /// if the App Group isn't enabled yet (e.g. in unit tests, or before the
    /// capability is wired up in Xcode).
    static let defaults: UserDefaults = {
        UserDefaults(suiteName: appGroup) ?? .standard
    }()

    // Keys used by both the app and the DeviceActivityMonitor extension.
    enum Key {
        static let famSelection = "famSelection"
        static let activeShield = "activeShield"   // Bool — extension toggles this
    }
}
