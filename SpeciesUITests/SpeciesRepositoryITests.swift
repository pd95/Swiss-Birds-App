//
//  SpeciesRepositoryTests.swift
//  SpeciesUITests
//
//  Created by Philipp on 24.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import XCTest
import SpeciesCore
@testable import SpeciesUI

class SpeciesRepositoryTests: XCTestCase {

    func test_isEmptyOnInit() async throws {
        let repository = makeSUT()

        XCTAssertEqual(repository.species, [])
        XCTAssertEqual(repository.filters.allTypes, [])
    }

    func test_refreshSpecies_fetchesSpeciesAndFilters() async throws {
        var fetchFiltersCalled = false
        var fetchSpeciesCalled = false
        let service = MockDataService(
            fetchFiltersHandler: { fetchFiltersCalled = true; return FilterCollection.example },
            fetchSpeciesHandler: { fetchSpeciesCalled = true; return Species.examples }
        )
        let repository = makeSUT(service: service)

        await repository.refreshSpecies()

        XCTAssertTrue(fetchFiltersCalled, "fetchFilters was called")
        XCTAssertTrue(fetchSpeciesCalled, "fetchSpecies was called")
        XCTAssertNotEqual(repository.species, [])
        XCTAssertNotEqual(repository.filters.allTypes, [])
    }

    func test_fetchDetails_fetchesDetails() async throws {
        var fetchDetailsCalled = false
        let mockedResult = SpeciesDetail.example
        let mockedResultID = mockedResult.id
        let service = MockDataService(fetchSpeciesDetailHandler: { _ in fetchDetailsCalled = true ; return mockedResult })
        let repository = makeSUT(service: service)

        let species = try await repository.fetchDetails(for: mockedResultID)

        XCTAssertTrue(fetchDetailsCalled, "fetchSpeciesDetail was called")
        XCTAssertEqual(species.id, mockedResultID)
    }

    // MARK: - Helper

    private func makeSUT(service: MockDataService = MockDataService(), file: StaticString = #filePath, line: UInt = #line) -> SpeciesRepository {
        let repository = SpeciesRepository(service: service)

        trackForMemoryLeaks(repository, file: file, line: line)

        return repository
    }

    private class MockDataService: DataService {
        enum Error: Swift.Error {
            case noHandlerDefined
        }

        var fetchFiltersHandler: () throws -> FilterCollection
        var fetchSpeciesHandler: () throws -> [Species]
        var fetchSpeciesDetailHandler: (Int) throws -> SpeciesDetail

        init(fetchFiltersHandler: @escaping () throws -> FilterCollection = { throw Error.noHandlerDefined }, fetchSpeciesHandler: @escaping () throws -> [Species] = { throw Error.noHandlerDefined }, fetchSpeciesDetailHandler: @escaping (Int) throws -> SpeciesDetail = { _ in throw Error.noHandlerDefined }) {
            self.fetchFiltersHandler = fetchFiltersHandler
            self.fetchSpeciesHandler = fetchSpeciesHandler
            self.fetchSpeciesDetailHandler = fetchSpeciesDetailHandler
        }

        func fetchFilters() async throws -> SpeciesCore.FilterCollection {
            try fetchFiltersHandler()
        }

        func fetchSpecies() async throws -> [SpeciesCore.Species] {
            try fetchSpeciesHandler()
        }

        func fetchSpeciesDetail(for speciesID: Int) async throws -> SpeciesCore.SpeciesDetail {
            try fetchSpeciesDetailHandler(speciesID)
        }
    }
}
