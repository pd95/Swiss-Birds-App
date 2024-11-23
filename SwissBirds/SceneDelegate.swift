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
            logger.error("\(#function, privacy: .public): invalid shortcut item type: \(shortcutItem.type, privacy: .public)")
            completionHandler(false)
            return
        }
        logger.info("\(#function, privacy: .public): request handling of url \(url, privacy: .public)")

        windowScene.open(url, options: nil, completionHandler: completionHandler)
    }
}
