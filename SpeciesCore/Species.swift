//
//  Species.swift
//  SpeciesCore
//
//  Created by Philipp on 15.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation

public struct Species: Identifiable, Equatable, Hashable {
    public let id: Int

    public let name: String
    public let synonyms: String
    public let alias: String
    public let voiceData: Bool

    public let filters: Set<Filter>

    public init(id: Int, name: String, synonyms: String, alias: String, voiceData: Bool, filters: Set<Filter> = .init()) {
        self.id = id
        self.name = name
        self.synonyms = synonyms
        self.alias = alias
        self.voiceData = voiceData
        self.filters = filters
    }
}

#if DEBUG
extension Species {
    public static var example = examples[0]
    public static var examples = [
        Species(id: 1150, name: "Eurasian Buzzard", synonyms: "Common Buzzard", alias: "common-buzzard", voiceData: true, filters: [
            Filter(type: "filterlebensraum", id: 5),
            Filter(type: "filterlebensraum", id: 7),
            Filter(type: "filterlebensraum", id: 8),
            Filter(type: "filterlebensraum", id: 9),
            Filter(type: "filternahrung", id: 9),
        ]),
        Species(id: 1200, name: "Golden Eagle", synonyms: "", alias: "golden-eagle", voiceData: true, filters: [
            Filter(type: "filterlebensraum", id: 4),
            Filter(type: "filternahrung", id: 1),
            Filter(type: "filternahrung", id: 9),
            Filter(type: "filternahrung", id: 14)
        ]),
        Species(id: 3800, name: "Eurasian Blue Tit", synonyms: "Blue Tit", alias: "eurasian-blue-tit", voiceData: true, filters: [
            Filter(type: "filterlebensraum", id: 5),
            Filter(type: "filterlebensraum", id: 7),
            Filter(type: "filterlebensraum", id: 10),
            Filter(type: "filternahrung", id: 5),
            Filter(type: "filternahrung", id: 6)
        ]),
        Species(id: 4060, name: "Black Redstart", synonyms: "", alias: "black-redstart", voiceData: true, filters: [
            Filter(type: "filterlebensraum", id: 4),
            Filter(type: "filterlebensraum", id: 10),
            Filter(type: "filternahrung", id: 5),
            Filter(type: "filternahrung", id: 7)
        ])
    ]
}
#endif
