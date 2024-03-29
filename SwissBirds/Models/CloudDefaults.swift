//
//  CloudDefaults.swift
//  SwissBirds
//
//  Created by Philipp on 05.07.21.
//  Copyright © 2021 Philipp. All rights reserved.
//

import Foundation
import os.log

/// CloudDefaults - a class to synchronize changes to `UserDefaults` to the `NSUbiquitousKeyValueStore` (=cloud) and back
/// Only UserDefaults keys starting with the `CloudDefaults.syncPrefix` are monitored and automatically synched to the cloud.
final class CloudDefaults: NSObject {
    static let shared = CloudDefaults()
    static let syncPrefix = "sync_"

    private var ignoreLocalChanges = false
    private var userDefaults: UserDefaults
    private var ubiquitousKeyValueStore: NSUbiquitousKeyValueStore
    private var notificationCenter: NotificationCenter

    private var synchronizedUserDefaultKeys = [String]()

    init(userDefaults: UserDefaults = .standard, ubiquitousKeyValueStore: NSUbiquitousKeyValueStore = .default, notificationCenter: NotificationCenter = .default) {
        self.userDefaults = userDefaults
        self.ubiquitousKeyValueStore = ubiquitousKeyValueStore
        self.notificationCenter = notificationCenter
        super.init()
    }

    deinit {
        notificationCenter.removeObserver(self)
        for keyPathString in synchronizedUserDefaultKeys {
            userDefaults.removeObserver(self, forKeyPath: keyPathString)
        }
    }

    /// Called upon application start, to ensure we do not miss any important iCloud update
    func start() {
        // register for UserDefault changes of known keys which need syncing
        synchronizedUserDefaultKeys = userDefaults.dictionaryRepresentation().keys.filter({ $0.hasPrefix(Self.syncPrefix)})
        for keyPathString in synchronizedUserDefaultKeys {
            userDefaults.addObserver(self, forKeyPath: keyPathString, options: .new, context: nil) // Use KVO obervation mechanism
        }

        // Register for UserDefaults change notifications to keep "synchronized keys" up-to-date
        notificationCenter.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: userDefaults, queue: .main, using: findNewSyncKeys
        )

        // register for notifications of all external changes
        notificationCenter.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: ubiquitousKeyValueStore,
            queue: .main,
            using: updateLocal
        )

        // Force iCloud sync to ensure a fresh copy
        if ubiquitousKeyValueStore.synchronize() == false {
            fatalError("App was not built with the proper iCloud entitlement requests?")
        }
        os_log("CloudDefaults.start: synchronized successfully")
    }

    /// Called whenever the application enters foreground state, to ensure the store is up-to-date
    func synchronize() {
        #if DEBUG
        let bit = ubiquitousKeyValueStore.bool(forKey: "fakeSyncBit")
        ubiquitousKeyValueStore.set(!bit, forKey: "fakeSyncBit")
        #endif
        if ubiquitousKeyValueStore.synchronize() {
            os_log("CloudDefaults.synchronize: success")
        } else {
            os_log("CloudDefaults.synchronize: error!!")
        }
    }

    /// This method is called whenever UserDefaults changes (=UserDefaults.didChangeNotification).
    /// We check here whether new sync-keys are added to UserDefaults, start observing those and push the values to the cloud
    private func findNewSyncKeys(_ notification: Notification) {
        os_log("CloudDefaults.findNewSyncKeys: %{public}@", notification.debugDescription)
        for (key, value) in userDefaults.dictionaryRepresentation() {
            guard key.hasPrefix(Self.syncPrefix) && synchronizedUserDefaultKeys.contains(key) == false else { continue }

            os_log("CloudDefaults.findNewSyncKeys: New key found %{public}@, adding observer and pushing value to cloud store", key)
            synchronizedUserDefaultKeys.append(key)
            userDefaults.addObserver(self, forKeyPath: key, options: .new, context: nil) // Use KVO observation mechanism
            ubiquitousKeyValueStore.set(value, forKey: key)
        }
    }

    /// This method synchronizes external changes (=NSUbiquitousKeyValueStore.didChangeExternallyNotification) to the UserDefaults store
    /// ensuring (by setting `ignoreLocalChanges`) that those are not synched back to the cloud.
    private func updateLocal(_ notification: Notification) {
        os_log("CloudDefaults: updateLocal: %{public}@", notification.debugDescription)
        ignoreLocalChanges = true

        for (key, value) in ubiquitousKeyValueStore.dictionaryRepresentation {
            guard key.hasPrefix(Self.syncPrefix) else { continue }
            os_log("CloudDefaults.updateRemote: Updating local value of %{public}@", key)
            userDefaults.set(value, forKey: key)
        }

        ignoreLocalChanges = false
    }

    /// This method is called whenever an observed UserDefaults key changes and pushes the new value to the cloud
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard ignoreLocalChanges == false else {
            os_log("CloudDefaults.observeValue: UserDefaults %{public}@ changed, but ignored", keyPath?.description ?? "-")
            return
        }
        guard let keyPath = keyPath,
              let newValue = change?[.newKey]
        else {
            os_log("CloudDefaults.observeValue: UserDefaults %{public}@ changed, but invalid keyPath or value provided", keyPath?.description ?? "-")
            return
        }

        os_log("CloudDefaults.observeValue: UserDefaults %{public}@ changed to %{public}@", keyPath, change?.debugDescription ?? "(none)")
        ubiquitousKeyValueStore.set(newValue, forKey: keyPath)
    }
}
