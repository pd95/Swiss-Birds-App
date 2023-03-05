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
        let repository = makeSUT()

        await repository.refreshSpecies()

        XCTAssertNotEqual(repository.species, [])
        XCTAssertNotEqual(repository.filters.allTypes, [])
    }

    // MARK: - Helper

    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> SpeciesRepository {
        let service = MockDataService()
        let repository = SpeciesRepository(service: service)

        trackForMemoryLeaks(service, file: file, line: line)
        trackForMemoryLeaks(repository, file: file, line: line)

        return repository
    }

    private class MockDataService: DataService {
        func fetchFilters() async throws -> FilterCollection {
            FilterCollection.example
        }

        func fetchSpecies() async throws -> [Species] {
            Species.examples
        }

        func fetchSpeciesDetail(for speciesID: Int) async throws -> SpeciesDetail {
            SpeciesDetail.example
        }
    }
}
