//
//  IntentHandler.swift
//  Swiss-BirdsIntent
//
//  Created by Philipp on 04.07.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        if intent is BirdOfTheDayIntent {
            return BirdOfTheDayHandler()
        }
//        else if intent is ShowBirdIntent {
//            return ShowBirdIntentHandler()
//        }
        fatalError("Unsupported intent of type: \(intent)")
    }
}
