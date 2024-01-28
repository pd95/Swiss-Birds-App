//
//  BirdOfTheDay.swift
//  SwissBirds
//
//  Created by Philipp on 28.01.2024.
//  Copyright © 2024 Philipp. All rights reserved.
//

import Foundation

struct BirdOfTheDay: Codable {
    var speciesID: Int
    var name: String
    var remoteURL: URL
    var fileURL: URL
    var loadingDate: Date

    static var example: BirdOfTheDay {
        guard let url = Bundle(for: DataFetcher.self).url(forResource: "Placeholder", withExtension: "jpg") else {
            fatalError("Placeholder.jpg is missing!")
        }
        return BirdOfTheDay(
            speciesID: 3800, name: "Blaumeise",
            remoteURL: URL(string: "https://www.vogelwarte.ch/wp-content/assets/images/bird/species/3800_0_9to4.jpg")!,
            fileURL: url,
            loadingDate: .now
        )
    }
}
