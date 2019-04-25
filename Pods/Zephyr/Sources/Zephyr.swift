//
//  Zephyr.swift
//  Zephyr
//
//  Created by Arthur Ariel Sabintsev on 11/2/15.
//  Copyright © 2015 Arthur Ariel Sabintsev. All rights reserved.
//

import Foundation
import UIKit

/// Enumerates the Local (`UserDefaults`) and Remote (`NSUNSUbiquitousKeyValueStore`) data stores
private enum ZephyrDataStore {
    case local  // UserDefaults
    case remote // NSUbiquitousKeyValueStore
}

@objcMembers
public final class Zephyr: NSObject {
    /// A debug flag.
    ///
    /// If **true**, then this will enable console log statements.
    ///
    /// By default, this flag is set to **false**.
    public static var debugEnabled = false

    /// If **true**, then `NSUbiquitousKeyValueStore.synchronize()` will be called immediately after any change is made.
    public static var syncUbiquitousKeyValueStoreOnChange = true

    /// A string containing the notification name that will be psoted when Zephyr receives updated data from iCloud.
    public static let keysDidChangeOnCloudNotification = Notification.Name("ZephyrKeysDidChangeOnCloudNotification")

    /// The singleton for Zephyr.
    private static let shared = Zephyr()

    /// A shared key that stores the last synchronization date between `UserDefaults` and `NSUbiquitousKeyValueStore`.
    private let ZephyrSyncKey = "ZephyrSyncKey"

    /// An array of keys that should be actively monitored for changes.
    private var monitoredKeys = [String]()

    /// An array of keys that are currently registered for observation.
    private var registeredObservationKeys = [String]()

    /// A queue used to serialize synchronization on monitored keys.
    private let zephyrQueue = DispatchQueue(label: "com.zephyr.queue")

    /// A session-persisted variable to directly access all of the `UserDefaults` elements.
    private var zephyrLocalStoreDictionary: [String: Any] {
        return userDefaults.dictionaryRepresentation()
    }

    /// A session-persisted variable to directly access all of the `NSUbiquitousKeyValueStore` elements.
    private var zephyrRemoteStoreDictionary: [String: Any] {
        return NSUbiquitousKeyValueStore.default.dictionaryRepresentation
    }

    // The `UserDefaults` object to sync with `NSUbiquitousKeyValueStore` (e.g., iCloud).
    private var userDefaults: UserDefaults = UserDefaults.standard

    /// Zephyr's initialization method.
    ///
    /// Do not call this method directly.
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(keysDidChangeOnCloud(notification:)),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(notification:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    /// Zephyr's de-initialization method.
    deinit {
        zephyrQueue.sync {
            for key in registeredObservationKeys {
                userDefaults.removeObserver(self, forKeyPath: key)
            }
        }
    }

    /// Zephyr's synchronization method.
    ///
    /// Zephyr will synchronize all `UserDefaults` with `NSUbiquitousKeyValueStore`.
    ///
    /// If one or more keys are passed, only those keys will be synchronized.
    ///
    /// - Parameters:
    ///     - keys: If you pass a one or more keys, only those key will be synchronized. If no keys are passed, than all `UserDefaults` will be synchronized with `NSUbiquitousKeyValueStore`.
    public static func sync(keys: String...) {

        if !keys.isEmpty {
            sync(keys: keys)
            return
        }

        switch shared.dataStoreWithLatestData() {
        case .local:
            printGeneralSyncStatus(finished: false, destination: .remote)
            shared.zephyrQueue.sync {
                shared.syncToCloud()
            }
            printGeneralSyncStatus(finished: true, destination: .remote)
        case .remote:
            printGeneralSyncStatus(finished: false, destination: .local)
            shared.zephyrQueue.sync {
                shared.syncFromCloud()
            }
            printGeneralSyncStatus(finished: true, destination: .local)
        }
    }

    /// Overloaded version of Zephyr's synchronization method, `sync(keys:)`.
    ///
    /// This method will synchronize an array of keys between `UserDefaults` and `NSUbiquitousKeyValueStore`.
    ///
    /// - Parameters:
    ///     - keys: An array of keys that should be synchronized between `UserDefaults` and `NSUbiquitousKeyValueStore`.
    public static func sync(keys: [String]) {

        switch shared.dataStoreWithLatestData() {
        case .local:
            printGeneralSyncStatus(finished: false, destination: .remote)
            shared.zephyrQueue.sync {
                shared.syncSpecificKeys(keys: keys, dataStore: .local)
            }
            printGeneralSyncStatus(finished: true, destination: .remote)
        case .remote:
            printGeneralSyncStatus(finished: false, destination: .local)
            shared.zephyrQueue.sync {
                shared.syncSpecificKeys(keys: keys, dataStore: .remote)
            }
            printGeneralSyncStatus(finished: true, destination: .local)
        }
    }

    /// Overloaded version of Zephyr's synchronization method, `sync(keys:)`.
    ///
    /// If a custom UserDefaults object is passed in, Zephyr will synchronize that rather than `UserDefaults.standard`.
    ///
    /// - Parameters:
    ///     - userDefaults: The `UserDefaults` object that should be synchronized with `UbiquitousKeyValueStore.default`.
    ///       default value is `UserDefaults.standard`.
    ///     - keys: If you pass a one or more keys, only those key will be synchronized. If no keys are passed, than all `UserDefaults` will be synchronized with `NSUbiquitousKeyValueStore`.
    public static func sync(keys: String..., userDefaults: UserDefaults = UserDefaults.standard) {
        shared.userDefaults = userDefaults
        sync(keys: keys)
    }

    /// Overloaded version of Zephyr's synchronization method, `sync(keys:)`.
    ///
    /// If a custom UserDefaults object is passed in, Zephyr will synchronize that rather than `UserDefaults.standard`.
    ///
    /// - Parameters:
    ///     - userDefaults: The `UserDefaults` object that should be synchronized with `UbiquitousKeyValueStore.default`
    ///       default value is `UserDefaults.standard`
    ///     - keys: An array of keys that should be synchronized between `UserDefaults` and `NSUbiquitousKeyValueStore`.
    public static func sync(keys: [String], userDefaults: UserDefaults = UserDefaults.standard) {
        shared.userDefaults = userDefaults
        sync(keys: keys)
    }

    /// Add specific keys to be monitored in the background. Monitored keys will automatically
    /// be synchronized between both data stores whenever a change is detected
    ///
    /// - Parameters:
    ///     - keys: Pass one or more keys that you would like to begin monitoring.
    public static func addKeysToBeMonitored(keys: [String]) {
        shared.zephyrQueue.sync {
            for key in keys {
                if shared.monitoredKeys.contains(key) == false {
                    shared.monitoredKeys.append(key)
                    shared.registerObserver(key: key)
                }
            }
        }
    }

    /// Overloaded version of the **addKeysToBeMonitored(keys:)** method.
    ///
    /// Add specific keys to be monitored in the background. Monitored keys will automatically
    /// be synchronized between both data stores whenever a change is detected
    ///
    /// - Parameters:
    ///     - keys: Pass one or more keys that you would like to begin monitoring.
    public static func addKeysToBeMonitored(keys: String...) {
        addKeysToBeMonitored(keys: keys)
    }

    /// Remove specific keys from being monitored in the background.
    ///
    /// - Parameters:
    ///    - keys: Pass one or more keys that you would like to stop monitoring.
    public static func removeKeysFromBeingMonitored(keys: [String]) {
        shared.zephyrQueue.sync {
            for key in keys {
                if shared.monitoredKeys.contains(key) == true {
                    shared.monitoredKeys = shared.monitoredKeys.filter {$0 != key }
                    shared.unregisterObserver(key: key)
                }
            }
        }
    }

    /// Overloaded version of the **removeKeysFromBeingMonitored(keys:)** method.
    ///
    /// Remove specific keys from being monitored in the background.
    ///
    /// - Parameters:
    ///     - keys: Pass one or more keys that you would like to stop monitoring.
    public static func removeKeysFromBeingMonitored(keys: String...) {
        removeKeysFromBeingMonitored(keys: keys)
    }

}

// MARK: - Helpers

private extension Zephyr {
    /// Compares the last sync date between `NSUbiquitousKeyValueStore` and `UserDefaults`.
    ///
    /// If no data exists in `NSUbiquitousKeyValueStore`, then `NSUbiquitousKeyValueStore` will synchronize with data from `UserDefaults`.
    /// If no data exists in `UserDefaults`, then `UserDefaults` will synchronize with data from `NSUbiquitousKeyValueStore`.
    ///
    /// - Returns: The persistent data store that has the newest data.
    func dataStoreWithLatestData() -> ZephyrDataStore {

        if let remoteDate = zephyrRemoteStoreDictionary[ZephyrSyncKey] as? Date,
            let localDate = zephyrLocalStoreDictionary[ZephyrSyncKey] as? Date {

            // If both localDate and remoteDate exist, compare the two, and then synchronize the data stores.
            return localDate.timeIntervalSince1970 > remoteDate.timeIntervalSince1970 ? .local : .remote

        } else {

            // If remoteDate doesn't exist, then assume local data is newer.
            guard let _ = zephyrRemoteStoreDictionary[ZephyrSyncKey] as? Date else {
                return .local
            }

            // If localDate doesn't exist, then assume that remote data is newer.
            guard let _ = zephyrLocalStoreDictionary[ZephyrSyncKey] as? Date else {
                return .remote
            }

            // If neither exist, synchronize local data store to iCloud.
            return .local
        }

    }

}

// MARK: - Synchronizers

private extension Zephyr {
    /// Synchronizes specific keys to/from `NSUbiquitousKeyValueStore` and `UserDefaults`.
    ///
    /// - Parameters:
    ///     - keys: Array of keys to synchronize.
    ///     - dataStore: Signifies if keys should be synchronized to/from iCloud.
    func syncSpecificKeys(keys: [String], dataStore: ZephyrDataStore) {
        for key in keys {
            switch dataStore {
            case .local:
                let value = zephyrLocalStoreDictionary[key]
                syncToCloud(key: key, value: value)
            case .remote:
                let value = zephyrRemoteStoreDictionary[key]
                syncFromCloud(key: key, value: value)
            }
        }
    }

    /// Synchronizes all `UserDefaults` to `NSUbiquitousKeyValueStore`.
    ///
    /// If a key is passed, only that key will be synchronized.
    ///
    /// - Parameters:
    ///     - key: If you pass a key, only that key will be updated in `NSUbiquitousKeyValueStore`.
    ///     - value: The value that will be synchronized. Must be passed with a key, otherwise, nothing will happen.
    func syncToCloud(key: String? = nil, value: Any? = nil) {
        let ubiquitousStore = NSUbiquitousKeyValueStore.default
        ubiquitousStore.set(Date(), forKey: ZephyrSyncKey)

        // Sync all defaults to iCloud if key is nil, otherwise sync only the specific key/value pair.
        guard let key = key else {
            for (key, value) in zephyrLocalStoreDictionary {
                unregisterObserver(key: key)
                ubiquitousStore.set(value, forKey: key)
                Zephyr.printKeySyncStatus(key: key, value: value, destination: .remote)
                if Zephyr.syncUbiquitousKeyValueStoreOnChange {
                    ubiquitousStore.synchronize()
                }
                registerObserver(key: key)
            }

            return
        }

        unregisterObserver(key: key)

        if let value = value {
            ubiquitousStore.set(value, forKey: key)
            Zephyr.printKeySyncStatus(key: key, value: value, destination: .remote)
        } else {
            NSUbiquitousKeyValueStore.default.removeObject(forKey: key)
            Zephyr.printKeySyncStatus(key: key, value: value, destination: .remote)
        }

        if Zephyr.syncUbiquitousKeyValueStoreOnChange {
            ubiquitousStore.synchronize()
        }

        registerObserver(key: key)
    }

    /// Synchronizes all `NSUbiquitousKeyValueStore` to `UserDefaults`.
    ///
    /// If a key is passed, only that key will be synchronized.
    ///
    /// - Parameters:
    ///     - key: If you pass a key, only that key will updated in `UserDefaults`.
    ///     - value: The value that will be synchronized. Must be passed with a key, otherwise, nothing will happen.
    func syncFromCloud(key: String? = nil, value: Any? = nil) {
        let defaults = userDefaults
        defaults.set(Date(), forKey: ZephyrSyncKey)

        // Sync all defaults from iCloud if key is nil, otherwise sync only the specific key/value pair.
        guard let key = key else {
            for (key, value) in zephyrRemoteStoreDictionary {
                unregisterObserver(key: key)
                defaults.set(value, forKey: key)
                Zephyr.printKeySyncStatus(key: key, value: value, destination: .local)
                registerObserver(key: key)
            }

            return
        }

        unregisterObserver(key: key)

        if let value = value {
            defaults.set(value, forKey: key)
            Zephyr.printKeySyncStatus(key: key, value: value, destination: .local)
        } else {
            defaults.set(nil, forKey: key)
            Zephyr.printKeySyncStatus(key: key, value: nil, destination: .local)
        }

        registerObserver(key: key)
    }

}

// MARK: - Observers

extension Zephyr {

    /// Adds key-value observation after synchronization of a specific key.
    ///
    /// - Parameters:
    ///     - key: The key that should be added and monitored.
    private func registerObserver(key: String) {
        if key == ZephyrSyncKey {
            return
        }

        if !registeredObservationKeys.contains(key) {

            userDefaults.addObserver(self, forKeyPath: key, options: .new, context: nil)
            registeredObservationKeys.append(key)

        }

        Zephyr.printObservationStatus(key: key, subscribed: true)
    }

    /// Removes key-value observation before synchronization of a specific key.
    ///
    /// - Parameters:
    ///     - key: The key that should be removed from being monitored.
    private func unregisterObserver(key: String) {
        if key == ZephyrSyncKey {
            return
        }

        if let index = registeredObservationKeys.firstIndex(of: key) {

            userDefaults.removeObserver(self, forKeyPath: key, context: nil)
            registeredObservationKeys.remove(at: index)

        }

        Zephyr.printObservationStatus(key: key, subscribed: false)
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, let object = object, monitoredKeys.contains(keyPath) else {
            return
        }

        // Synchronize changes if key is monitored and if key is currently registered to respond to changes
        zephyrQueue.async {
            if self.registeredObservationKeys.contains(keyPath) {
                if object is UserDefaults {
                    self.userDefaults.set(Date(), forKey: self.ZephyrSyncKey)
                }

                self.syncSpecificKeys(keys: [keyPath], dataStore: .local)
            }
        }
    }
}

// MARK: - Observers (Objective-C)

@objc
extension Zephyr {

    /// Observation method for UIApplicationWillEnterForegroundNotification
    func willEnterForeground(notification: Notification) {
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    ///  Observation method for `NSUbiquitousKeyValueStore.didChangeExternallyNotification`
    func keysDidChangeOnCloud(notification: Notification) {
        if notification.name == NSUbiquitousKeyValueStore.didChangeExternallyNotification {
            guard let userInfo = (notification as NSNotification).userInfo,
                let cloudKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String],
                let localStoredDate = zephyrLocalStoreDictionary[ZephyrSyncKey] as? Date,
                let remoteStoredDate = zephyrRemoteStoreDictionary[ZephyrSyncKey] as? Date,
                remoteStoredDate.timeIntervalSince1970 > localStoredDate.timeIntervalSince1970 else {
                    return
            }

            for key in monitoredKeys where cloudKeys.contains(key) {
                syncSpecificKeys(keys: [key], dataStore: .remote)
            }

            // Notify any observers that we have finished synchronizing an update from iCloud.
            NotificationCenter.default.post(name: Zephyr.keysDidChangeOnCloudNotification, object: nil)
        }
    }

}

// MARK: - Loggers

private extension Zephyr {
    /// Prints Zephyr's current sync status if
    ///
    /// - Parameters:
    ///     - debugEnabled == true
    ///     - finished: The current status of syncing
    static func printGeneralSyncStatus(finished: Bool, destination dataStore: ZephyrDataStore) {

        if debugEnabled == true {
            let destination = dataStore == .local ? "FROM iCloud" : "TO iCloud."

            var message = "Started synchronization \(destination)"
            if finished == true {
                message = "Finished synchronization \(destination)"
            }

            printStatus(status: message)
        }
    }

    /// Prints the key, value, and destination of the synchronized information if debugEnabled == true
    ///
    /// - Parameters:
    ///     - key: The key being synchronized.
    ///     - value: The value being synchronized.
    ///     - destination: The data store that is receiving the updated key-value pair.
    static func printKeySyncStatus(key: String, value: Any?, destination dataStore: ZephyrDataStore) {
        if debugEnabled == true {
            let destination = dataStore == .local ? "FROM iCloud" : "TO iCloud."

            guard let value = value else {
                let message = "Synchronized key '\(key)' with value 'nil' \(destination)"
                printStatus(status: message)
                return
            }

            let message = "Synchronized key '\(key)' with value '\(value)' \(destination)"
            printStatus(status: message)
        }
    }

    /// Prints the subscription state for a specific key if debugEnabled == true
    ///
    /// - Parameters:
    ///     - key: The key being synchronized.
    ///     - subscribed: The subscription status of the key.
    static func printObservationStatus(key: String, subscribed: Bool) {
        if debugEnabled {
            let subscriptionState = subscribed == true ? "Subscribed" : "Unsubscribed"
            let preposition = subscribed == true ? "for" : "from"

            let message = "\(subscriptionState) '\(key)' \(preposition) observation."
            printStatus(status: message)
        }
    }

    /// Prints a status to the console if
    ///
    /// - Parameters:
    ///     - debugEnabled == true
    ///     - status: The string that should be printed to the console.
    static func printStatus(status: String) {
        if debugEnabled == true {
            print("[Zephyr] \(status)")
        }
    }
}
