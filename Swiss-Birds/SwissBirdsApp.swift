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
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    @StateObject private var appState = AppState.shared
    @StateObject private var favoritesManager = FavoritesManager.shared

    init() {
        #if DEBUG
        if CommandLine.arguments.contains("enable-testing") {
            UIView.setAnimationsEnabled(false)
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
    }
}
