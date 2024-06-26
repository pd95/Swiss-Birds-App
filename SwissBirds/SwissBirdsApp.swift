//
//  SwissBirdsApp.swift
//  SwissBirds
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
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(favoritesManager)
                .onContinueUserActivity(NSUserActivity.showBirdTheDayActivityType, perform: appState.handleUserActivity)
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
