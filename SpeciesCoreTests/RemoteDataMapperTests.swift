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

        XCTAssertEqual(filters, [])
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
        XCTAssertEqual(filters, [item1, item2])
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


    // MARK: - Helper
    func makeFilter(typeName: String, id: Int, name: String) -> (Filter, json: [String: Any]) {
        let item = Filter(type: .filterType(for: typeName), id: id, name: name)

        let json = [
            "type": typeName,
            "filter_id": String(id),
            "filter_name": name
        ].compactMapValues { $0 }

        return (item, json)
    }

    func makeSpecies(id: Int = 123, name: String = "Globi", synonyms: String = "Papagei", alias: String? = nil, voiceData: Bool = true) -> (Species, json: [String: Any]) {
        let alias = alias ?? name.lowercased()
        let item = Species(id: id, name: name, synonyms: synonyms, alias: alias, voiceData: voiceData)

        let json = [
            "artid": String(id),
            "artname": name,
            "synonyme": synonyms,
            "alias": alias,
            "voice": voiceData ? "1" : "0",
        ].compactMapValues { $0 }

        return (item, json)
    }

    func makeItemsJSON(_ json: [[String: Any]]) -> Data {
        return try! JSONSerialization.data(withJSONObject: json)
    }
}
