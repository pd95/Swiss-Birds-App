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

    private var setupDone = false
    private var ignoreLocalChanges = false
    private var userDefaults: UserDefaults
    private var ubiquitousKeyValueStore: NSUbiquitousKeyValueStore
    private var notificationCenter: NotificationCenter

    private var synchronizedUserDefaultKeys = [String]()
    private let logger = Logger(subsystem: "SettingsStore", category: "general")

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

    private var canSync: Bool {
        let token = FileManager.default.ubiquityIdentityToken
        logger.info("\(#function): iCloud syncing \(token == nil ? "disabled" : "enabled")")
        return token != nil
    }

    /// Called upon application start, to ensure we do not miss any important iCloud update
    private func start() {
        logger.debug("\(#function)")
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
        if canSync && ubiquitousKeyValueStore.synchronize() == false {
            fatalError("App was not built with the proper iCloud entitlement requests?")
        }
        setupDone = true
        logger.debug("\(#function): synchronized successfully")
    }

    /// Called whenever the application enters foreground state, to ensure the store is up-to-date
    func synchronize() {
        logger.debug("\(#function)")
        guard canSync else {
            logger.debug("\(#function): cannot sync")
            return
        }
        if !setupDone {
            logger.debug("\(#function): setup not done")
            start()
        } else {
            logger.debug("\(#function): synching")
            #if DEBUG
            let bit = ubiquitousKeyValueStore.bool(forKey: "fakeSyncBit")
            ubiquitousKeyValueStore.set(!bit, forKey: "fakeSyncBit")
            #endif
            if ubiquitousKeyValueStore.synchronize() {
                logger.debug("\(#function): success")
            } else {
                logger.debug("\(#function): error")
            }
        }
    }

    /// This method is called whenever UserDefaults changes (=UserDefaults.didChangeNotification).
    /// We check here whether new sync-keys are added to UserDefaults, start observing those and push the values to the cloud
    private func findNewSyncKeys(_ notification: Notification) {
        logger.debug("\(#function): \(notification.name.rawValue, privacy: .public)")
        for (key, value) in userDefaults.dictionaryRepresentation() {
            guard key.hasPrefix(Self.syncPrefix) && synchronizedUserDefaultKeys.contains(key) == false else { continue }

            logger.debug("\(#function): New key found \(key, privacy: .public), adding observer and pushing value to cloud store")
            synchronizedUserDefaultKeys.append(key)
            userDefaults.addObserver(self, forKeyPath: key, options: .new, context: nil) // Use KVO observation mechanism
            ubiquitousKeyValueStore.set(value, forKey: key)
        }
    }

    /// This method synchronizes external changes (=NSUbiquitousKeyValueStore.didChangeExternallyNotification) to the UserDefaults store
    /// ensuring (by setting `ignoreLocalChanges`) that those are not synched back to the cloud.
    private func updateLocal(_ notification: Notification) {
        logger.debug("\(#function): \(notification.debugDescription, privacy: .public)")
        guard let userInfo = notification.userInfo else { return }
        guard let reasonForChange = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else { return }

        switch reasonForChange {
        case NSUbiquitousKeyValueStoreServerChange:
            logger.info("\(#function): Server change")
        case NSUbiquitousKeyValueStoreInitialSyncChange:
            logger.info("\(#function): Initial Sync change")
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            logger.info("\(#function): Quota Violation change")
        case NSUbiquitousKeyValueStoreAccountChange:
            logger.info("\(#function): Account change")
        default:
            logger.error("Unsupported change iCloud KVS change reason: \(reasonForChange)")
            return
        }

        ignoreLocalChanges = true

        for (key, value) in ubiquitousKeyValueStore.dictionaryRepresentation {
            guard key.hasPrefix(Self.syncPrefix) else { continue }
            logger.debug("\(#function): Updating local value of \(key, privacy: .public)")
            userDefaults.set(value, forKey: key)
        }

        ignoreLocalChanges = false
    }

    /// This method is called whenever an observed UserDefaults key changes and pushes the new value to the cloud
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard ignoreLocalChanges == false else {
            logger.debug("\(#function): UserDefaults \(keyPath?.description ?? "-", privacy: .public) changed, but ignored")
            return
        }
        guard let keyPath = keyPath,
              let newValue = change?[.newKey]
        else {
            logger.debug("\(#function): UserDefaults \(keyPath?.description ?? "-", privacy: .public) but invalid keyPath or value provided")
            return
        }

        logger.debug("\(#function): UserDefaults \(keyPath, privacy: .public) changed to \(String(describing: newValue))")
        ubiquitousKeyValueStore.set(newValue, forKey: keyPath)
    }
}
