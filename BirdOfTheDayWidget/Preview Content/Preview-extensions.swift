//
//  Bundle-sampleData.swift
//  BirdOfTheDayWidgetExtension
//
//  Created by Philipp on 03.05.23.
//  Copyright © 2023 Philipp. All rights reserved.
//

import UIKit

extension SimpleEntry {
    static var exampleReal: SimpleEntry {
        let image = UIImage(resource: .bod0900)
        return SimpleEntry(speciesID: 900, name: "Schellente", date: Date.distantFuture, image: image, bgImage: image)
    }

    static var exampleReal2: SimpleEntry {
        let image = UIImage(resource: .bod1060)
        return SimpleEntry(speciesID: 1060, name: "Mittelsäger", date: Date.distantFuture, image: image, bgImage: image)
    }
}
