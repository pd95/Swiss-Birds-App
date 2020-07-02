//
//  SettingsStore.swift
//  Swiss-Birds
//
//  Created by Philipp on 29.06.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation

class SettingsStore: ObservableObject {

    static let shared = SettingsStore()

    private init() {}

    @UserDefault(key: UserDefaults.Keys.startupCheckBirdOfTheDay, defaultValue: true)
    var startupCheckBirdOfTheDay: Bool

    @UserDefault(key: UserDefaults.Keys.voiceDataOverConstrainedNetworkAccess, defaultValue: false)
    var voiceDataOverConstrainedNetworkAccess: Bool

    func setupForTesting() {
        if CommandLine.arguments.contains("no-settings") {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        }

        if CommandLine.arguments.contains("no-birdoftheday") {
            startupCheckBirdOfTheDay = false
        }
    }
}

extension UserDefaults {

    fileprivate struct Keys {
        static let startupCheckBirdOfTheDay = "startupCheckBirdOfTheDay"
        static let voiceDataOverConstrainedNetworkAccess = "voiceDataOverConstrainedNetworkAccess"
    }
}
