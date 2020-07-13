//
//  ShowBirdIntentHandler.swift
//  Swiss-BirdsIntent
//
//  Created by Philipp on 04.07.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation
import os.log
import Intents

class ShowBirdIntentHandler: NSObject, ShowBirdIntentHandling {

    lazy private var knownBirds = { SettingsStore.shared.sharedBirds }()

    func provideBirdOptions(for intent: ShowBirdIntent, with completion: @escaping ([Bird]?, Error?) -> Void) {
        os_log("🟡 provideBirdOptions()")
        let birds = knownBirds.map { (sharedBird) -> Bird in
            let (name, id) = sharedBird
            return Bird(identifier: "\(id)", display: name)
        }
        completion(birds, nil)
    }

    func resolveBird(for intent: ShowBirdIntent, with completion: @escaping (BirdResolutionResult) -> Void) {
        os_log("🟡 resolveBird()")
        guard let bird = intent.bird else {
            completion(BirdResolutionResult.needsValue())
            return
        }
        completion(BirdResolutionResult.success(with: bird))
    }

    func handle(intent: ShowBirdIntent, completion: @escaping (ShowBirdIntentResponse) -> Void) {
        os_log("🟡 handle(): bird: %{public}@", intent.bird?.description ?? "nil")

        guard let bird = intent.bird, let speciesID = Int(bird.identifier ?? "") else {
            return
        }

        let userActivity = NSUserActivity(activityType: NSUserActivity.showBirdActivityType)
        userActivity.userInfo = [NSUserActivity.ActivityKeys.birdID.rawValue: speciesID]
        os_log("🟡 handle(): preparing userActivity %{public}@", userActivity.activityType.description)

        let response = ShowBirdIntentResponse(code: .continueInApp, userActivity: userActivity)
        completion(response)
    }

}
