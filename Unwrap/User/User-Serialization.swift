//
//  User-Serialization.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation

extension User {
    static let liveUserKey = "User"
    static let testUserKey = "TestUser"
    /// Where the time of the last save is stored. Existing installs already use this name, so it must not change.
    static let syncTimestampKey = "ZephyrSyncKey"

    /// Returns true when the app is running as the host for its unit tests.
    static var isRunningTests: Bool {
        isRunningTests(in: ProcessInfo.processInfo.environment)
    }

    static func isRunningTests(in environment: [String: String]) -> Bool {
        environment["IS_TESTING"] == "1"
    }

    /// Loads a user from UserDefaults, or returns nil if there was none.
    static func load(testMode: Bool? = nil) -> User? {
        let key = (testMode ?? isRunningTests) ? testUserKey : liveUserKey
        return decode(UserDefaults.standard.data(forKey: key))
    }

    /// Saves a user to user defaults.
    func save(testMode: Bool? = nil) {
        guard let data = encoded() else {
            print("Failed to save user.")
            return
        }

        let isTestUser = testMode ?? User.isRunningTests
        if isTestUser {
            UserDefaults.standard.set(data, forKey: User.testUserKey)
            return
        }

        let timestamp = Date.now
        let cloudStore = NSUbiquitousKeyValueStore.default

        UserDefaults.standard.set(data, forKey: User.liveUserKey)
        UserDefaults.standard.set(timestamp, forKey: User.syncTimestampKey)
        cloudStore.set(data, forKey: User.liveUserKey)
        cloudStore.set(timestamp, forKey: User.syncTimestampKey)
        cloudStore.synchronize()
    }

    /// Destroys any existing user so we can be sure we have a blank slate when testing.
    static func destroyTestUser() {
        UserDefaults.standard.removeObject(forKey: testUserKey)
    }

    /// Selects the complete local or cloud record at launch by timestamp:
    /// local wins only when it is strictly newer.
    static func synchronize() -> User? {
        let defaults = UserDefaults.standard
        let cloudStore = NSUbiquitousKeyValueStore.default
        cloudStore.synchronize()

        let localData = defaults.data(forKey: liveUserKey)
        let cloudData = cloudStore.data(forKey: liveUserKey)
        let localUser = decode(localData)
        let cloudUser = decode(cloudData)
        let localDate = defaults.object(forKey: syncTimestampKey) as? Date
        let cloudDate = cloudStore.object(forKey: syncTimestampKey) as? Date

        if localRecordWins(localDate: localDate, cloudDate: cloudDate) {
            if let localData, let localUser {
                copyLocal(localData, to: cloudStore)
                return localUser
            }

            if let cloudData, let cloudUser {
                copyCloud(cloudData, to: defaults)
                return cloudUser
            }
        } else {
            if let cloudData, let cloudUser {
                copyCloud(cloudData, to: defaults)
                return cloudUser
            }

            if let localData, let localUser {
                copyLocal(localData, to: cloudStore)
                return localUser
            }
        }

        return nil
    }

    /// Adopts an update that another device has just published, retaining the raw
    /// bytes for forward compatibility. Incoming updates always replace the local
    /// copy: our timestamp records when this device last saved, not when its
    /// progress last changed, so it can't tell us which record is really newer.
    static func synchronizeAfterCloudChange() -> User? {
        guard
            let cloudData = NSUbiquitousKeyValueStore.default.data(forKey: liveUserKey),
            let cloudUser = decode(cloudData)
        else {
            return nil
        }

        copyCloud(cloudData, to: .standard)
        return cloudUser
    }

    static func requestCloudSynchronization() {
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    static func localRecordWins(localDate: Date?, cloudDate: Date?) -> Bool {
        switch (localDate, cloudDate) {
        case let (localDate?, cloudDate?):
            localDate > cloudDate
        case (_?, nil), (nil, nil):
            true
        case (nil, _?):
            false
        }
    }

    private static func copyLocal(_ data: Data, to cloudStore: NSUbiquitousKeyValueStore) {
        cloudStore.set(Date.now, forKey: syncTimestampKey)
        cloudStore.set(data, forKey: liveUserKey)
        cloudStore.synchronize()
    }

    private static func copyCloud(_ data: Data, to defaults: UserDefaults) {
        defaults.set(Date.now, forKey: syncTimestampKey)
        defaults.set(data, forKey: liveUserKey)
    }

    private func encoded() -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(self)
    }

    private static func decode(_ data: Data?) -> User? {
        guard let data, data.isEmpty == false else { return nil }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(User.self, from: data)
    }
}
