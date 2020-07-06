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

    @UserDefault(key: UserDefaults.Keys.sharedBirds, defaultValue: [:], storage: UserDefaults(suiteName: "group.swiss-birds")!)
    var sharedBirds: [String:Int]

    func setupForTesting() {
        if CommandLine.arguments.contains("no-settings") {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        }

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
        if appVersion != currentVersion {
            appVersion = currentVersion
        }
    }
}

extension UserDefaults {

    fileprivate struct Keys {
        static let startupCheckBirdOfTheDay = "startupCheckBirdOfTheDay"
        static let voiceDataOverConstrainedNetworkAccess = "voiceDataOverConstrainedNetworkAccess"
        static let reset = "reset"
        static let appVersion = "appVersion"
        static let sharedBirds = "sharedBirds"
    }
}
