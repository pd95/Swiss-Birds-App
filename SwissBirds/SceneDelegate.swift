//
//  SceneDelegate.swift
//  SwissBirds
//
//  Created by Philipp on 23.11.2024.
//  Copyright © 2024 Philipp. All rights reserved.
//

import os.log
import SwiftUI
import UIKit

final class SceneDelegate: NSObject, UIWindowSceneDelegate {
    @Environment(\.openURL) var openURL

    let logger = Logger(subsystem: "SceneDelegate", category: "general")

    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        guard let url = URL(string: shortcutItem.type) else {
            logger.error("\(#function): invalid shortcut item type: \(shortcutItem.type)")
            completionHandler(false)
            return
        }
        logger.info("\(#function): request handling of url \(url)")

        windowScene.open(url, options: nil, completionHandler: completionHandler)
    }
}
