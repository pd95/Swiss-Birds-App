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

    static let shared = SettingsStore()

    var anyCancellable: AnyCancellable?

    private init() {
        anyCancellable = NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .sink { [weak self](x) in
                os_log("UserDefaults.didChangeNotification %{public}@", x.description)
                self?.checkAndSetVersionAndBuildNumber()
            }
        checkAndSetVersionAndBuildNumber()
    }

    @UserDefault(key: UserDefaults.Keys.reset, defaultValue: false)
    var reset: Bool

    @UserDefault(key: UserDefaults.Keys.appVersion, defaultValue: "-")
    var appVersion: String

    @UserDefault(key: UserDefaults.Keys.startupCheckBirdOfTheDay, defaultValue: true)
    var startupCheckBirdOfTheDay: Bool

    @UserDefault(key: UserDefaults.Keys.voiceDataOverConstrainedNetworkAccess, defaultValue: false)
    var voiceDataOverConstrainedNetworkAccess: Bool

    @UserDefault(key: "groupColumn", defaultValue: "")
    var groupColumn: String

    @UserDefault(key: UserDefaults.Keys.favoriteSpecies, defaultValue: [])
    var favoriteSpecies: [Int]

    func setupForTesting() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)

        if CommandLine.arguments.contains("no-birdoftheday") {
            startupCheckBirdOfTheDay = false
        }
    }

    private func checkAndSetVersionAndBuildNumber() {
        if reset {
            let domain = Bundle.main.bundleIdentifier!
            os_log("Resetting all settings for %{public}@", domain)
            UserDefaults.standard.removePersistentDomain(forName: domain)
        }
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let currentVersion = "\(version) (\(build))"

        // Migrate old favorites to Cloud-syncing favorites key
        if let oldFavorites = UserDefaults.standard.array(forKey: UserDefaults.Keys.favoriteSpeciesOld) as? [Int] {
            os_log("Migrating old favorites to cloud-synched favorites %{public}@", oldFavorites)
            favoriteSpecies = oldFavorites
            UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.favoriteSpeciesOld)
        }

        if appVersion != currentVersion {
            appVersion = currentVersion
        }
    }
}

extension UserDefaults {

    struct Keys {
        static let startupCheckBirdOfTheDay = "startupCheckBirdOfTheDay"
        static let voiceDataOverConstrainedNetworkAccess = "voiceDataOverConstrainedNetworkAccess"
        static let reset = "reset"
        static let appVersion = "appVersion"
        static let favoriteSpeciesOld = "favoriteSpecies"
        static let favoriteSpecies = "sync_favoriteSpecies"
    }
    
    @objc dynamic var sync_favoriteSpecies: [Int] {
        get {
            array(forKey: Keys.favoriteSpecies) as? [Int] ?? []
        }
        set {
            setValue(newValue, forKey: Keys.favoriteSpecies)
        }
    }
}
