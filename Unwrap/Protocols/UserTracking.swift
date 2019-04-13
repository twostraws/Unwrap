//
//  UserTracking.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2018 Hacking with Swift.
//

import UIKit

extension Notification.Name {
    /// The notification message that gets sent when any part of the user's status has changed.
    static let userStatusChanged = Notification.Name("UnwrapUserStatusChanged")
}

/// A method that conforming types must implement in order to be notified when the user's data has changed.
@objc protocol UserTracking {
    @objc func userDataChanged()
    @objc func userCloudDataChanged()
}

extension UserTracking {
    /// A method that sets up this object to be notified when user data changes. Conforming types should not need to override this implementation.
    func registerForUserChanges() {
        let defaults = NSUbiquitousKeyValueStore.default

        NotificationCenter.default.addObserver(self, selector: #selector(userDataChanged), name: .userStatusChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userCloudDataChanged), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: nil)
        defaults.synchronize()

    }
}
