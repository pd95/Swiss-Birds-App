//
//  RemoteDataMapper-SpeciesDetailDTO.swift
//  SpeciesCore
//
//  Created by Philipp on 22.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation

extension RemoteDataMapper {
    struct SpeciesDetailDTO: Decodable {
        let id, name, facts, identificationCriteria: String
        let properties: SpeciesProperties
        let speciesNames: SpeciesNames
        let voice: String
        let speciesImage: [SpeciesImages]
        let population: SpeciesPopulation
        let statusInCH: String

        let atlasText, atlasLiterature, atlasAuthor, atlasTrend: String
        let maps, charts: [String]
        let alias_de, alias_fr, alias_it, alias_en: String

        enum CodingKeys: String, CodingKey {
            case id = "artid"
            case name = "artname"
            case facts = "infos"
            case identificationCriteria = "merkmale"
            case properties = "eigenschaften"
            case speciesNames = "artnamen"
            case voice = "voice"
            case speciesImage = "artbilder"
            case population = "bestand"
            case statusInCH = "status_in_ch"

            case atlasText = "atlastext"
            case atlasLiterature = "atlas_literatur"
            case atlasAuthor = "atlas_autor"
            case atlasTrend = "atlas_entwicklung"

            case maps = "maps"
            case charts = "charts"

            case alias_de = "alias_de"
            case alias_fr = "alias_fr"
            case alias_it = "alias_it"
            case alias_en = "alias_en"
        }

        // MARK: - SpeciesImages
        struct SpeciesImages: Decodable {
            let author, imageDescription: String

            enum CodingKeys: String, CodingKey {
                case author = "autor"
                case imageDescription = "bezeichnung"
            }
        }

        // MARK: - SpeciesNames
        struct SpeciesNames: Decodable {
            let name_de: String
            let name_fr: String
            let name_it: String
            let name_rr: String
            let name_en: String
            let name_sp: String
            let name_ho: String
            let scientificName: String
            let scientificFamily: String
            let synonyms: String

            enum CodingKeys: String, CodingKey {
                case name_de = "artname_de"
                case name_fr = "artname_frz"
                case name_it = "artname_ital"
                case name_rr = "artname_rr"
                case name_en = "artname_engl"
                case name_sp = "artname_span"
                case name_ho = "artname_holl"
                case scientificName = "artname_lat"
                case scientificFamily = "familie_wiss"
                case synonyms = "synonyme"
            }
        }

        // MARK: - SpeciesPopulation
        struct SpeciesPopulation: Decodable {
            let atlasPopulation, atlasPopulationDate: String
            let redListCH, priorityInRecoveryPrograms: String

            enum CodingKeys: String, CodingKey {
                case atlasPopulation = "atlas_bestand"
                case atlasPopulationDate = "atlas_bestand_datum"
                case redListCH = "rote_liste_ch"
                case priorityInRecoveryPrograms = "prioritaetsart_artenfoerderung"
            }
        }

        // MARK: - SpeciesProperties
        struct SpeciesProperties: Decodable {
            let group, length, wingSpan, weight: String
            let food, habitat, migrationBehavior, nestSite: String
            let incubation, broodsPerYear, clutchSize, nestlingStage: String
            let maximumAgeEURING, maximumAgeCH: String

            enum CodingKeys: String, CodingKey {
                case group = "vogelgruppe"
                case length = "laenge_cm"
                case wingSpan = "spannweite_cm"
                case weight = "gewicht_g"
                case food = "nahrung"
                case habitat = "lebensraum"
                case migrationBehavior = "zugverhalten"
                case nestSite = "brutort"
                case incubation = "brutdauer_tage"
                case broodsPerYear = "jahresbruten"
                case clutchSize = "gelegegroesse"
                case nestlingStage = "nestlingsdauer_flugfaehigkeit_tage"
                case maximumAgeEURING = "hoechstalter_euring"
                case maximumAgeCH = "hoechstalter_ch"
            }
        }

        // MARK: - SpeciesFilter
        struct SpeciesFilter: Decodable {
            let filters: [(type: String, filterIDs: String)]

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: FilterCodingKeys.self)
                var filters = [(String,String)]()
                for key in container.allKeys {
                    let filterIDs = try container.decode(String.self, forKey: key)

                    let type = String(key.stringValue.dropFirst(6))
                    filters.append((type, filterIDs))
                }
                self.filters = filters
            }
        }
    }
}
