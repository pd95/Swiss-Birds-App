//
//  Bundle-sampleData.swift
//  BirdOfTheDayWidgetExtension
//
//  Created by Philipp on 03.05.23.
//  Copyright © 2023 Philipp. All rights reserved.
//

import Foundation

extension Bundle {
    static var placeholderJpg: URL {
        guard let url = Bundle.main.url(forResource: "Placeholder.jpg", withExtension: nil) else {
            fatalError("Unable to load Placeholder.jpg data from bundle")
        }
        return url
    }
}
