//
//  SettingsStore.swift
//  Swiss-Birds
//
//  Created by Philipp on 29.06.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation

class SettingsStore: ObservableObject {

    @UserDefault(key: UserDefaults.Keys.startupCheckBirdOfTheDay, defaultValue: true)
    var startupCheckBirdOfTheDay: Bool


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
    }
}
