//
//  BirdOfTheDayHandler.swift
//  Swiss-Birds
//
//  Created by Philipp on 06.07.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation
import os.log
import Intents
import Combine

class BirdOfTheDayHandler: NSObject, BirdOfTheDayIntentHandling {

    // We use these UserDefault values to persist data between confirm() and handle()
    @UserDefault(key: "birdOfTheDayURL", defaultValue: "",
                 storage: UserDefaults(suiteName: "group.swiss-birds")!)
    var birdOfTheDayURL: String

    @UserDefault(key: "birdOfTheDaySpeciesID", defaultValue: -1,
                 storage: UserDefaults(suiteName: "group.swiss-birds")!)
    var birdOfTheDaySpeciesID: Int


    var cancellable: AnyCancellable?

    func confirm(intent: BirdOfTheDayIntent, completion: @escaping (BirdOfTheDayIntentResponse) -> Void) {
        os_log("confirm()")
        cancellable = VdsAPI.getBirdOfTheDaySpeciesIDandURL()
            .map {Optional.some($0)}
            .replaceError(with: nil)
            .sink(receiveValue: { (birdOfTheDay) in
                self.birdOfTheDaySpeciesID = birdOfTheDay?.speciesID ?? -1
                self.birdOfTheDayURL = birdOfTheDay?.url.absoluteString ?? ""
                os_log("confirm().sink() received: speciesID: %ld, url: %{public}@", self.birdOfTheDaySpeciesID, self.birdOfTheDayURL)

                completion(BirdOfTheDayIntentResponse(code: birdOfTheDay != nil ? .ready : .failure, userActivity: nil))
            })
    }

    func handle(intent: BirdOfTheDayIntent, completion: @escaping (BirdOfTheDayIntentResponse) -> Void) {
        os_log("handle(): speciesID: %ld, url: %{public}@", self.birdOfTheDaySpeciesID, self.birdOfTheDayURL)
        let speciesID = birdOfTheDaySpeciesID
        if let url = URL(string: birdOfTheDayURL), speciesID > -1 {

            let knownBirds = SettingsStore.shared.sharedBirds
            let birdName = knownBirds.first(where: { $0.value == speciesID })?.key ?? "Unknown"

            // Activity to be executed when response is tapped
            let userActivity = NSUserActivity(activityType: NSUserActivity.showBirdActivityType)
            userActivity.userInfo = [NSUserActivity.ActivityKeys.birdID.rawValue: speciesID]
            os_log("handle(): preparing userActivity %{public}@", userActivity.activityType.description)

            // Prepare success response with all relevant details for display
            let response = BirdOfTheDayIntentResponse(code: .success, userActivity: userActivity)
            response.birdName = birdName
            response.birdSpeciesID = NSNumber(integerLiteral: speciesID)
            response.birdImageURL = url

            completion(response)
        }
        else {
            completion(BirdOfTheDayIntentResponse(code: .failure, userActivity: nil))
        }
    }
}
