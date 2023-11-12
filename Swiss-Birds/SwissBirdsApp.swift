//
//  SwissBirdsApp.swift
//  Swiss-Birds
//
//  Created by Philipp on 12.11.2023.
//  Copyright © 2023 Philipp. All rights reserved.
//

import SwiftUI

@main
struct SwissBirdsApp: App {
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var appState = AppState.shared
    @StateObject private var favoritesManager = FavoritesManager.shared

    init() {
        #if DEBUG
        if CommandLine.arguments.contains("enable-testing") {
            UIView.setAnimationsEnabled(false)
            SettingsStore.shared.setupForTesting()
        }
        #endif

        // Enable cloud synched UserDefaults
        CloudDefaults.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(favoritesManager)
        }
        .onChange(of: scenePhase) { newValue in
            print("scenePhase", newValue)
            switch newValue {
            case .active:
                CloudDefaults.shared.synchronize()
            default:
                break
            }
        }
    }
}
