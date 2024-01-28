//
//  Bundle-sampleData.swift
//  BirdOfTheDayWidgetExtension
//
//  Created by Philipp on 03.05.23.
//  Copyright © 2023 Philipp. All rights reserved.
//

import UIKit

extension SimpleEntry {

    static func entry(speciesID: Int, name: String, filename: String) -> SimpleEntry {
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            fatalError("Missing resource \(filename)!")
        }
        let bird = BirdOfTheDay(
            speciesID: speciesID,
            name: name,
            remoteURL: URL(string: "https://www.vogelwarte.ch/wp-content/assets/images/bird/species/\(speciesID)_0_9to4.jpg")!,
            fileURL: url,
            loadingDate: .now
        )
        let image = UIImage.resizedImage(from: url, displaySize: CGSize(width: 155*3, height: 155), displayScale: 2)
        return SimpleEntry(bird: bird, image: image)
    }

    static var exampleReal: SimpleEntry {
        entry(speciesID: 900, name: "Schellente", filename: "bod_0900.jpg")
    }

    static var exampleReal2: SimpleEntry {
        entry(speciesID: 1060, name: "Mittelsäger", filename: "bod_1060.jpg")
    }
}
