//
//  RemoteDataMapperTests.swift
//  SpeciesCoreTests
//
//  Created by Philipp on 15.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import XCTest
import SpeciesCore

class RemoteDataMapperTests: XCTestCase {

    // MARK: Test filter mapping
    func test_mapFilter_throwsOnInvalidData() throws {
        let data = anyData()

        XCTAssertThrowsError(
            try RemoteDataMapper.mapFilter(data)
         )
    }

    func test_mapFilter_deliversNoItemsOnEmptyJSONList() throws {
        let data = makeItemsJSON([])

        let filters = try RemoteDataMapper.mapFilter(data)

        XCTAssertEqual(filters.allTypes, [])
    }

    func test_mapFilter_throwsOnInvalidFilterID() throws {
        var (_, json) = makeFilter(typeName: "greatness", id: 1, name: "true")
        json["filter_id"] = "bla"
        let data = makeItemsJSON([json])

        XCTAssertThrowsError(
            try RemoteDataMapper.mapFilter(data)
         )
    }

    func test_mapFilter_deliversItemsOnJSONItems() throws {
        let (item1, json1) = makeFilter(typeName: "greatness", id: 1, name: "true")
        let (item2, json2) = makeFilter(typeName: "greatness", id: 0, name: "false")
        let data = makeItemsJSON([json1, json2])

        let filters = try RemoteDataMapper.mapFilter(data)
        XCTAssertEqual(filters.filters(for: "greatness"), [item1, item2])
    }

    // MARK: Test species mapping
    func test_mapSpecies_throwsOnInvalidData() throws {
        let data = anyData()

        XCTAssertThrowsError(
            try RemoteDataMapper.mapSpecies(data)
         )
    }

    func test_mapSpecies_deliversNoItemsOnEmptyJSONList() throws {
        let data = makeItemsJSON([])

        let species = try RemoteDataMapper.mapSpecies(data)

        XCTAssertEqual(species, [])
    }

    func test_mapSpecies_throwsOnInvalidID() throws {
        var (_, json) = makeSpecies()
        json["artid"] = "bla"
        let data = makeItemsJSON([json])

        XCTAssertThrowsError(
            try RemoteDataMapper.mapSpecies(data)
         )
    }

    func test_mapSpecies_deliversItemsOnJSONItems() throws {
        let (item1, json1) = makeSpecies(id: 123, name: "Globi", synonyms: "Papagei")
        let (item2, json2) = makeSpecies(id: 321, name: "Pingu", synonyms: "Pinguin")
        let data = makeItemsJSON([json1, json2])

        let species = try RemoteDataMapper.mapSpecies(data)
        XCTAssertEqual(species, [item1, item2])
    }

    func test_mapSpecies_mapsFiltersCorrectly() throws {
        let filters: Set<Filter> = [Filter(type: "greatness", id: 0, name: nil), Filter(type: "greatness", id: 1, name: nil), Filter(type: "rarity", id: 1, name: nil)]
        let (species, json) = makeSpecies(filter: filters)
        let data = makeItemsJSON([json])

        let mappedSpecies = try RemoteDataMapper.mapSpecies(data)

        XCTAssertEqual(mappedSpecies.first, species)
    }

    func test_mapSpeciesDetails_works() throws {
        let test = (id: 123, name: "Globi", facts: "A blue penguin")
        let data = makeSpeciesDetailsJSON(id: test.id, name: test.name, facts: test.facts)

        let mappedDetails = try RemoteDataMapper.mapSpeciesDetail(data, language: "en")

        XCTAssertEqual(mappedDetails.id, test.id)
        XCTAssertEqual(mappedDetails.name, test.name)
        XCTAssertEqual(mappedDetails.facts, test.facts)
    }

    // MARK: - Helper
    func makeFilter(typeName: String, id: Int, name: String) -> (Filter, json: [String: Any]) {
        let item = Filter(type: FilterType(typeName), id: id, name: name)

        let json = [
            "type": typeName,
            "filter_id": String(id),
            "filter_name": name
        ].compactMapValues { $0 }

        return (item, json)
    }

    func makeSpecies(id: Int = 123, name: String = "Globi", synonyms: String = "Papagei", alias: String? = nil, voiceData: Bool = true, filter: Set<Filter> = []) -> (Species, json: [String: Any]) {
        let alias = alias ?? name.lowercased()
        let item = Species(id: id, name: name, synonyms: synonyms, alias: alias, voiceData: voiceData, filters: filter)

        // Basic species data
        var json = [
            "artid": String(id),
            "artname": name,
            "synonyme": synonyms,
            "alias": alias,
            "voice": voiceData ? "1" : "0",
        ]

        // Transform all filters to json fields prefixed with "filter"
        for filter in filter {
            let fieldName = "filter"+filter.type.name
            if let existingIDs = json[fieldName] {
                json[fieldName] = existingIDs+",\(filter.id)"
            } else {
                json[fieldName] = String(filter.id)
            }
        }

        // Remove empty values
        json = json.compactMapValues { $0 }

        return (item, json)
    }

    func makeItemsJSON(_ json: [[String: Any]]) -> Data {
        return try! JSONSerialization.data(withJSONObject: json)
    }

    func makeSpeciesDetailsJSON(id: Int, name: String, facts: String) -> Data {
        // An example JSON structure with all fields currently found
        """
        {
          "artid": "\(id)",
          "artname": "\(name)",
          "infos": "\(facts)",
          "merkmale": "",
          "eigenschaften": {
            "vogelgruppe": "Buntings",
            "laenge_cm": "16-18",
            "spannweite_cm": "30-32",
            "gewicht_g": "26-40",
            "nahrung": "insects, seeds",
            "lebensraum": "tundra-like ridges,...",
            "zugverhalten": "short-distance migr...",
            "brutort": "ground",
            "brutdauer_tage": "12-13",
            "jahresbruten": "1-2",
            "gelegegroesse": "4-6",
            "nestlingsdauer_flugfaehigkeit_tage": "10-12",
            "hoechstalter_euring": "9 years 6 month",
            "hoechstalter_ch": ""
          },
          "artnamen": {
            "artname_de": "Schneeammer",
            "artname_lat": "Plectrophenax nival...",
            "artname_frz": "Bruant des neiges",
            "artname_ital": "Zigolo delle nevi",
            "artname_rr": "marena da naiv",
            "artname_engl": "Snow Bunting",
            "artname_span": "Escribano Nival",
            "artname_holl": "Sneeuwgors",
            "familie_wiss": "Calcariidae",
            "synonyme": "Snow Bunting"
          },
          "voice": "1",
          "artbilder": [
            {
              "autor": "John Doe",
              "bezeichnung": "male"
            },
            {
              "autor": "Will Smith",
              "bezeichnung": "female"
            }
          ],
          "bestand": {
            "atlas_bestand": "",
            "atlas_bestand_datum": "",
            "rote_liste_ch": "",
            "prioritaetsart_artenfoerderung": ""
          },
          "status_in_ch": "Species that would ...",
          "filternahrung": "9;14",
          "filterlebensraum": "3",
          "filterhaeufigeart": "0",
          "filterrotelistech": "",
          "filtervogelgruppe": "48",
          "filterentwicklungatlas": "",
          "atlastext": "",
          "atlas_literatur": "",
          "atlas_autor": "",
          "atlas_entwicklung": "",
          "maps": [
            "overview_map",
            "density",
            "density_change",
            "distribution",
            "winter"
          ],
          "charts": [
            "index",
            "altitude",
            "altitude_change",
            "annual_cycle"
          ],
          "alias_de": "sterntaucher",
          "alias_fr": "plongeon-catmarin",
          "alias_it": "strolaga-minore",
          "alias_en": "red-throated-loon"
        }
        """.data(using: .utf8)!
    }
}
