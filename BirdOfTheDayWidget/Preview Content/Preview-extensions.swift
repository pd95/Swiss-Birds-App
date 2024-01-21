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
        guard let url = URL(resource: URLResource(name: filename)) else {
            fatalError("Missing resource \(filename)!")
        }
        let image = UIImage.resizedImage(from: url, displaySize: CGSize(width: 155*3, height: 155), displayScale: 2)
        return SimpleEntry(speciesID: speciesID, name: name, date: .distantFuture, image: image)
    }

    static var exampleReal: SimpleEntry {
        entry(speciesID: 900, name: "Schellente", filename: "bod_0900.jpg")
    }

    static var exampleReal2: SimpleEntry {
        entry(speciesID: 1060, name: "Mittelsäger", filename: "bod_1060.jpg")
    }
}
