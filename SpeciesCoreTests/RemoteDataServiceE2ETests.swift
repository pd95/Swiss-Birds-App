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

    func test_fetchFilters_succeedsFromWeb() async throws {
        let dataService = RemoteDataService(dataClient: RemoteDataClient(urlSession: .init(configuration: .ephemeral)))

        let filters = try await dataService.fetchFilters()
        XCTAssertFalse(filters.isEmpty)
    }

    func test_fetchFilters_deliversSameForAllLanguages() async throws {
        var allFilters = [String: [Filter]]()
        for language in RemoteDataService.supportedLanguages {
            let dataService = RemoteDataService(dataClient: RemoteDataClient(urlSession: .init(configuration: .ephemeral)), language: "de")
            let filters = try await dataService.fetchFilters()
            XCTAssertFalse(filters.isEmpty)

            allFilters[language] = filters
        }

        let counts = allFilters.mapValues(\.count)
        let deCount = counts["de"]!
        XCTAssertTrue(counts.values.allSatisfy({ $0 == deCount }), "All languages should have the number of filters \(deCount): \(counts)")
    }
}
