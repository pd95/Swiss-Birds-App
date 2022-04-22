//
//  RemoteDataServiceE2ETests.swift
//  SpeciesCoreTests
//
//  Created by Philipp on 15.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import XCTest
import SpeciesCore

class RemoteDataServiceE2ETests: XCTestCase {

    // MARK: Test filter fetching

    func test_fetchFilters_succeedsFromWeb() async throws {
        let dataService = makeSUT()

        let filters = try await dataService.fetchFilters()
        XCTAssertNotEqual(filters.allTypes, [], "Should successfully fetch filters")
    }

    func test_fetchFilters_deliversSameForAllLanguages() async throws {
        var allFilters = [String: FilterCollection]()
        for language in RemoteDataService.supportedLanguages {
            let dataService = makeSUT(language: language)

            let filters = try await dataService.fetchFilters()
            XCTAssertNotEqual(filters.allTypes, [])

            allFilters[language] = filters
        }

        let counts = allFilters.mapValues( { filters in
            filters.allTypes.map({ filters.filters(for: $0).count })
                .reduce(into: 0, { $0 += $1 })
        })
        let deCount = counts["de"]!
        XCTAssertTrue(counts.values.allSatisfy({ $0 == deCount }), "All languages should have the number of filters \(deCount): \(counts)")
    }

    // MARK: Test species fetching

    func test_fetchSpecies_succeedsFromWeb() async throws {
        let dataService = makeSUT()

        let filters = try await dataService.fetchSpecies()
        XCTAssertFalse(filters.isEmpty)
    }

    func test_fetchSpecies_deliversSameForAllLanguages() async throws {
        var allSpecies = [String: [Species]]()
        for language in RemoteDataService.supportedLanguages {
            let dataService = makeSUT(language: language)

            let species = try await dataService.fetchSpecies()
            XCTAssertFalse(species.isEmpty)

            allSpecies[language] = species
        }

        let counts = allSpecies.mapValues(\.count)
        let deCount = counts["de"]!
        XCTAssertTrue(counts.values.allSatisfy({ $0 == deCount }), "All languages should have the number of species \(deCount): \(counts)")
    }

    // MARK: Test species detail fetching

    func test_fetchSpeciesDetails_succeedsFromWeb() async throws {
        let dataService = makeSUT()

        let speciesID = 3800
        let details = try await dataService.fetchSpeciesDetail(for: speciesID)
        XCTAssertEqual(details.id, speciesID)
        XCTAssertEqual(details.synonyms, "Blue Tit")
    }

    // MARK: - Helpers
    func makeSUT(language: String = "en") -> RemoteDataService {
        let urlSession = URLSession(configuration: .ephemeral)
        let client = RemoteDataClient(urlSession: urlSession)
        return RemoteDataService(dataClient: client, language: language)
    }
}
