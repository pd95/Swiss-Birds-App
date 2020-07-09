//
//  ShowBirdIntentHandler.swift
//  Swiss-BirdsIntent
//
//  Created by Philipp on 04.07.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation
import Intents

class ShowBirdIntentHandler: NSObject, ShowBirdIntentHandling {
    lazy private var knownBirds = { SettingsStore.shared.sharedBirds }()

    func provideNameOptions(for intent: ShowBirdIntent, with completion: @escaping ([String]?, Error?) -> Void) {
        completion(Array(knownBirds.keys), nil)
    }

    func resolveName(for intent: ShowBirdIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        guard let name = intent.name else {
            completion(INStringResolutionResult.needsValue())
            return
        }
        completion(INStringResolutionResult.success(with: name))
    }

    func handle(intent: ShowBirdIntent, completion: @escaping (ShowBirdIntentResponse) -> Void) {

        guard let name = intent.name else {
            return
        }
        print("Suche nach \(name)")

        let knownBirds = SettingsStore.shared.sharedBirds
        var foundBirdIDs = [Int]()
        if let birdId = knownBirds[name] {
            foundBirdIDs.append(birdId)
        }

        let userActivity = NSUserActivity(activityType: NSUserActivity.showBirdActivityType)
        userActivity.userInfo = [NSUserActivity.ActivityKeys.birdID.rawValue: foundBirdIDs.first!]

        let response = ShowBirdIntentResponse(code: .continueInApp, userActivity: userActivity)
        completion(response)
    }

}
