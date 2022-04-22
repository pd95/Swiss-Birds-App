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
//    public enum NameLanguage: String {
//        case german = "de", french = "fr", italian = "it", rhaetoRoman = "rr"
//        case english = "en", spanish = "es", dutch = "du"
//    }
//    public let speciesNames: [NameLanguage : String]
//    public let alias: [NameLanguage : String]

    // Filters
    public let filters: Set<Filter>
}
