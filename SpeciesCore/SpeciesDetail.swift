//
//  SpeciesDetail.swift
//  SpeciesCore
//
//  Created by Philipp on 15.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation

public struct SpeciesDetail: Identifiable {
    public let id: Int

    public let name: String
    public let facts: String
    public let identificationCriteria: String
    public let group: String

    public let length: String
    public let weight: String
    public let wingSpan: String

    public let food: String
    public let habitat: String

    public let clutchSize: String
    public let nestSite: String
    public let incubation: String
    public let nestlingStage: String
    public let broodsPerYear: String

    public let migrationBehavior: String

    public let maximumAgeEURING: String
    public let maximumAgeCH: String

    public let redListCH: String
    public let statusInCH: String
    public let priorityInRecoveryPrograms: Bool?

    // Synonyms and names
    public let synonyms: String
    public let scientificName: String
    public let scientificFamily: String
    public let speciesNames: [NameLanguage: String]
    public let alias: [NameLanguage: String]

    // Filters
    public let filters: Set<Filter>
}

#if DEBUG
extension SpeciesDetail {
    public static var example = SpeciesDetail(
        id: 1200,
        name: "Golden Eagle",
        facts: "The “King of the Skies” reaches a wingspan of up to 2.2 metres. The Golden Eagle is the only large predator in Switzerland to have survived the days of ruthless persecution during which the Bearded Vulture, the lynx, the wolf and the brown bear were exterminated. Meanwhile, the population of the Golden Eagle has recovered and is now almost saturated in the Alps. Due to the large number of unpaired single Golden Eagles, territorial pairs are repeatedly involved in disputes. They are therefore regularly absent from the eyrie, which reduces breeding success.",
        identificationCriteria: "",
        group: "Hawks, Vultures and Eagles",
        length: "75-88",
        weight: "2850-6700",
        wingSpan: "190-225",
        food: "carcasses, mammals, birds",
        habitat: "alpine habitats",

        clutchSize: "2",
        nestSite: "crevices, trees",
        incubation: "43-44",
        nestlingStage: "74-80",
        broodsPerYear: "1",

        migrationBehavior: "resident",
        maximumAgeEURING: "32 years 0 month",
        maximumAgeCH: "",

        redListCH: "Near Threatened (NT)",
        statusInCH: "scarce year-round",
        priorityInRecoveryPrograms: false,

        synonyms: "Golden Eagle",
        scientificName: "Aquila chrysaetos",
        scientificFamily: "Accipitridae",
        speciesNames: [
            "de": "Steinadler",
            "fr": "Aigle royal",
            "it": "Aquila reale",
            "rr": "evla (da la pizza)",
            "en": "Golden Eagle",
            "es": "Águila Real",
            "du": "Steenarend",
        ],
        alias: [
            "de": "steinadler",
            "fr": "aigle-royal",
            "it": "aquila-reale",
            "en": "golden-eagle"
        ],

        filters: [
            Filter(type: "filternahrung", id: 1),
            Filter(type: "filternahrung", id: 9),
            Filter(type: "filternahrung", id: 14),
            Filter(type: "filterlebensraum", id: 4),
            Filter(type: "filterhaeufigeart", id: 0),
            Filter(type: "filterrotelistech", id: 2),
            Filter(type: "filtervogelgruppe", id: 18),
            Filter(type: "filterentwicklungatlas", id: 2),
        ]
    )
}
#endif
