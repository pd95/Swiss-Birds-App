//
//  Swiss_BirdsTests.swift
//  Swiss_BirdsTests
//
//  Created by Philipp on 30.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import XCTest
import Combine
@testable import Swiss_Birds

class Swiss_BirdsTests: XCTestCase {

    // MARK: - Testing SettingsStore
    func test_SettingsStore_validDefaults() {
        let defaults = UserDefaults(suiteName: #function)!
        let settings = SettingsStore(userDefaults: defaults)

        XCTAssertEqual(settings.reset, false)
        XCTAssertEqual(settings.startupCheckBirdOfTheDay, true)
        XCTAssertEqual(settings.voiceDataOverConstrainedNetworkAccess, false)
        XCTAssertEqual(settings.groupColumn, "")
        XCTAssertEqual(settings.favoriteSpecies, [])

        XCTAssertNotEqual(settings.appVersion, "-")
    }

    func test_SettingsStore_reset_changesBackToDefaults() {
        let defaults = UserDefaults(suiteName: #function)!
        let settings = SettingsStore(userDefaults: defaults)
        let exp = expectation(description: #function)

        settings.startupCheckBirdOfTheDay = false
        settings.reset = true

        var cancellable: AnyCancellable?
        cancellable = defaults.publisher(for: \.reset)
            .sink { value in
                print("🟡 reset set to \(value)")
                if value == false {
                    print("🟡 Checking for default values")
                    XCTAssertEqual(settings.startupCheckBirdOfTheDay, true)
                    XCTAssertEqual(settings.reset, false)
                    exp.fulfill()
                    cancellable?.cancel()
                }
            }

        wait(for: [exp], timeout: 5.0)  // We do not know how long it will take! :-(
    }

    // MARK: - Testing AppState
    func test_AppState_runsInitialLoad() {
        let appState = AppState()
        let exp = expectation(description: #function)

        XCTAssertTrue(appState.initialLoadRunning, "Initial load should be running after creation.")
        var cancellable: AnyCancellable?
        cancellable = appState.objectWillChange
            .sink { _ in
                if appState.initialLoadRunning == false {
                    exp.fulfill()
                    cancellable?.cancel()
                }
            }

        wait(for: [exp], timeout: 10.0)  // We do not know how long it will take! :-(
    }

    func test_AppState_loadsAllSpecies() {
        let appState = AppState()
        let exp = expectation(description: #function)

        XCTAssertEqual(appState.allSpecies.count, 0, "Initial species array must be empty.")
        var cancellable: AnyCancellable?
        cancellable = appState.$allSpecies
            .dropFirst()                 // HACK: there is an issue here: first update is setting an empty array!
            .sink { species in
                XCTAssertGreaterThan(species.count, 0)
                exp.fulfill()
                cancellable?.cancel()
            }

        wait(for: [exp], timeout: 10.0)  // We do not know how long it will take! :-(
    }
}
