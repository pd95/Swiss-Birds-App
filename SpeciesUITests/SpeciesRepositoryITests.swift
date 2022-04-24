//
//  SpeciesRepositoryTests.swift
//  SpeciesUITests
//
//  Created by Philipp on 24.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import XCTest
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
        let repository = SpeciesRepository(language: "en")

        trackForMemoryLeaks(repository, file: file, line: line)

        return repository
    }
}
