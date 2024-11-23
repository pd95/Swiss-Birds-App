//
//  SettingsStore.swift
//  SwissBirds
//
//  Created by Philipp on 29.06.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation
import Combine
import os.log

class SettingsStore {

    enum Keys {
        static let startupCheckBirdOfTheDay = "startupCheckBirdOfTheDay"
        static let voiceDataOverConstrainedNetworkAccess = "voiceDataOverConstrainedNetworkAccess"
        static let reset = "reset"
        static let appVersion = "appVersion"
        static let favoriteSpeciesOld = "favoriteSpecies"
        static let favoriteSpecies = "sync_favoriteSpecies"
    }

    static let shared = SettingsStore()

    let userDefaults: UserDefaults

    private var anyCancellable: AnyCancellable?
    private let logger = Logger(subsystem: "SettingsStore", category: "general")

    init(userDefaults: UserDefaults = .standard) {

        self.userDefaults = userDefaults
        self._reset.storage = userDefaults
        self._appVersion.storage = userDefaults
        self._startupCheckBirdOfTheDay.storage = userDefaults
        self._voiceDataOverConstrainedNetworkAccess.storage = userDefaults
        self._groupColumn.storage = userDefaults
        self._favoriteSpecies.storage = userDefaults

        anyCancellable = NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification, object: userDefaults)
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .sink { [weak self](_) in
                self?.logger.debug("UserDefaults.didChangeNotification received")
                self?.checkAndSetVersionAndBuildNumber()
            }
        checkAndSetVersionAndBuildNumber()
    }

    @UserDefault(key: Keys.reset, defaultValue: false)
    var reset: Bool

    @UserDefault(key: Keys.appVersion, defaultValue: "-")
    var appVersion: String

    @UserDefault(key: Keys.startupCheckBirdOfTheDay, defaultValue: true)
    var startupCheckBirdOfTheDay: Bool

    @UserDefault(key: Keys.voiceDataOverConstrainedNetworkAccess, defaultValue: false)
    var voiceDataOverConstrainedNetworkAccess: Bool

    @UserDefault(key: "groupColumn", defaultValue: "")
    var groupColumn: String

    @UserDefault(key: Keys.favoriteSpecies, defaultValue: [])
    var favoriteSpecies: [Int]

    func setupForTesting() {
        removeAllSettings()

        if CommandLine.arguments.contains("no-birdoftheday") {
            startupCheckBirdOfTheDay = false
        }
    }

    // The following function should run "isolated" only once.
    // By updating userDefaults more changes may trigger more calls to this function.
    private var checkRunning = false
    private func checkAndSetVersionAndBuildNumber() {
        logger.debug("\(#function, privacy: .public) running on \(Thread.current.description, privacy: .public)")
        guard checkRunning == false, Thread.isMainThread == true else {
            return
        }
        checkRunning = true

        if reset {
            removeAllSettings()
        }
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let currentVersion = "\(version) (\(build))"

        // Migrate old favorites to Cloud-syncing favorites key
        if let oldFavorites = userDefaults.array(forKey: Keys.favoriteSpeciesOld) as? [Int] {
            logger.debug("Migrating old favorites to cloud-synched favorites \(oldFavorites.description, privacy: .public)")
            favoriteSpecies = oldFavorites
            userDefaults.removeObject(forKey: Keys.favoriteSpeciesOld)
        }

        if appVersion != currentVersion {
            logger.debug("\(#function, privacy: .public) set appVersion")
            appVersion = currentVersion
        }

        checkRunning = false
    }

    /// Remove all stored settings
    /// Ensures "reset == true" during the whole process-
    func removeAllSettings() {
        logger.debug("\(#function, privacy: .public)")
        reset = true
        for element in userDefaults.dictionaryRepresentation() {
            if element.key == Keys.reset { continue }
            userDefaults.removeObject(forKey: element.key)
        }
        userDefaults.removeObject(forKey: Keys.reset)
    }
}

extension UserDefaults {

    @objc dynamic var reset: Bool {
        get {
            bool(forKey: SettingsStore.Keys.reset)
        }
        set {
            setValue(newValue, forKey: SettingsStore.Keys.reset)
        }
    }
}
