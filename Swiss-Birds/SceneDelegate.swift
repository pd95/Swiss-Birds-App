//
//  SceneDelegate.swift
//  Swiss-Birds
//
//  Created by Philipp on 30.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import os.log
import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        os_log("scene(_, willConnectTo:,options:) => activities %ld", connectionOptions.userActivities.count)

        if CommandLine.arguments.contains("enable-testing") {
            SettingsStore.shared.setupForTesting()
        }
        else {
            if let activity = session.stateRestorationActivity {
                AppState.shared.restore(from: activity)
            }
        }

        if let shortcutItem = connectionOptions.shortcutItem {
            handleShortcutItem(shortcutItem)
        }

        for activity in connectionOptions.userActivities {
            handleUserActivity(activity)
        }

        let contentView = ContentView()
            .environmentObject(AppState.shared)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        os_log("windowScene(_, performActionFor:, completionHandler:) => item %{public}@", shortcutItem.description)
        let handled = handleShortcutItem(shortcutItem)
        completionHandler(handled)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        print("sceneDidBecomeActive")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        print("sceneWillResignActive")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("sceneWillEnterForeground")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        print("sceneDidEnterBackground")
    }
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        let activity = NSUserActivity(activityType: Bundle.main.activityType)
        AppState.shared.store(in: activity)
        return activity
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        os_log("scene(_, continue:) => activity %{public}@", userActivity.activityType)
        handleUserActivity(userActivity)
    }

    func handleUserActivity(_ userActivity: NSUserActivity) {
        print("handleUserActivity(\(userActivity.activityType))")

        let state = AppState.shared

        if userActivity.activityType == NSUserActivity.showBirdActivityType {
            guard let birdID = userActivity.userInfo?[NSUserActivity.ActivityKeys.birdID.rawValue] as? Int
            else {
                print("Missing parameter birdID for \(userActivity.activityType)")
                return
            }

            print("handleUserActivity: birdID=\(birdID)")
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                state.showBird(birdID)
            }
        }
        else if userActivity.activityType == NSUserActivity.showBirdTheDayActivityType {
            print("handleUserActivity: showing bird of the day \(state.birdOfTheDay.debugDescription)")
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                state.checkBirdOfTheDay(showAlways: true)
            }
        }
        else {
            print("Skipping unsupported \(userActivity.activityType)")
            return
        }
        print("current state: ", state)
    }

    @discardableResult
    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        os_log("handleShortcutItem(shortcutItem: %{public}@)", shortcutItem.type)

        if shortcutItem.type == "BirdOfTheDay" {
            let appState = AppState.shared
            appState.checkBirdOfTheDay(showAlways: true)
            return true
        }
        return false
    }
}
