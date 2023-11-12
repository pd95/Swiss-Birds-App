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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(favoritesManager)
        }
    }
}
