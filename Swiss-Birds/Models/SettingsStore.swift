//
//  SettingsStore.swift
//  Swiss-Birds
//
//  Created by Philipp on 29.06.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation
import Combine
import os.log

class SettingsStore: ObservableObject {

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

    init(userDefaults: UserDefaults = .standard) {

        self.userDefaults = userDefaults
        self._reset.storage = userDefaults
        self._appVersion.storage = userDefaults
        self._startupCheckBirdOfTheDay.storage = userDefaults
        self._voiceDataOverConstrainedNetworkAccess.storage = userDefaults
        self._groupColumn.storage = userDefaults
        self._favoriteSpecies.storage = userDefaults

        anyCancellable = NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification, object: userDefaults)
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .sink { [weak self](x) in
                os_log("UserDefaults.didChangeNotification %{public}@", x.description)
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
        userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)

        if CommandLine.arguments.contains("no-birdoftheday") {
            startupCheckBirdOfTheDay = false
        }
    }

    private func checkAndSetVersionAndBuildNumber() {
        if reset {
            let domain = Bundle.main.bundleIdentifier!
            os_log("Resetting all settings for %{public}@", domain)
            userDefaults.removePersistentDomain(forName: domain)
        }
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let currentVersion = "\(version) (\(build))"

        // Migrate old favorites to Cloud-syncing favorites key
        if let oldFavorites = userDefaults.array(forKey: Keys.favoriteSpeciesOld) as? [Int] {
            os_log("Migrating old favorites to cloud-synched favorites %{public}@", oldFavorites)
            favoriteSpecies = oldFavorites
            userDefaults.removeObject(forKey: Keys.favoriteSpeciesOld)
        }

        if appVersion != currentVersion {
            appVersion = currentVersion
        }
    }
}
