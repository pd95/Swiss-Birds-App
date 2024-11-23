//
//  AppDelegate.swift
//  SwissBirds
//
//  Created by Philipp on 23.11.2024.
//  Copyright © 2024 Philipp. All rights reserved.
//

import os.log
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    let logger = Logger(subsystem: "AppDelegate", category: "general")

    // MARK: UIApplicationDelegate protocol

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Override point for customization after application launch.
        logger.debug("\(#function, privacy: .public): \(AppState.shared.description, privacy: .public)")
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        logger.debug("\(#function, privacy: .public) configuring a new scene")
        let sceneConfiguration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = SceneDelegate.self

        return sceneConfiguration
    }
}
