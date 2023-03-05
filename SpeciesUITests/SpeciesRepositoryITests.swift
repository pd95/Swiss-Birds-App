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
        let service = DataServiceStub()
        let repository = makeSUT(service: service)

        // Does not call any service on init
        XCTAssertEqual(service.fetchFiltersRequestCount, 0, "fetchFilters was never called")
        XCTAssertEqual(service.fetchSpeciesRequestCount, 0, "fetchSpecies was never called")
        XCTAssertEqual(service.fetchSpeciesDetailRequestCount, 0, "fetchSpecies was never called")

        XCTAssertEqual(repository.species, [])
        XCTAssertEqual(repository.filters.allTypes, [])
    }

    func test_refreshSpecies_fetchesSpeciesAndFilters() async throws {
        let service = DataServiceStub(
            fetchFiltersResult: .success(.example),
            fetchSpeciesResult: .success(Species.examples)
        )
        let repository = makeSUT(service: service)

        await repository.refreshSpecies()

        XCTAssertEqual(service.fetchFiltersRequestCount, 1, "fetchFilters was called once")
        XCTAssertEqual(service.fetchSpeciesRequestCount, 1, "fetchSpecies was called once")
        XCTAssertEqual(service.fetchSpeciesDetailRequestCount, 0, "fetchSpecies was never called")
        XCTAssertNotEqual(repository.species, [])
        XCTAssertNotEqual(repository.filters.allTypes, [])
    }

    func test_fetchDetails_fetchesDetails() async throws {
        let mockedResult = SpeciesDetail.example
        let mockedResultID = mockedResult.id
        let service = DataServiceStub(fetchSpeciesDetailResult: .success(mockedResult))
        let repository = makeSUT(service: service)

        let species = try await repository.fetchDetails(for: mockedResultID)

        XCTAssertEqual(service.fetchFiltersRequestCount, 0, "fetchFilters was never called")
        XCTAssertEqual(service.fetchSpeciesRequestCount, 0, "fetchSpecies was never called")
        XCTAssertEqual(service.fetchSpeciesDetailRequestCount, 1, "fetchSpecies was called once")
        XCTAssertEqual(species.id, mockedResultID)
    }

    // MARK: - Helper

    private func makeSUT(service: DataServiceStub = DataServiceStub(), file: StaticString = #filePath, line: UInt = #line) -> SpeciesRepository {
        let repository = SpeciesRepository(service: service)

        trackForMemoryLeaks(repository, file: file, line: line)

        return repository
    }

    private class DataServiceStub: DataService {
        enum Error: Swift.Error {
            case noHandlerDefined
        }

        var fetchFiltersRequestCount = 0
        var fetchFiltersResult: Result<FilterCollection, Error>

        var fetchSpeciesRequestCount = 0
        var fetchSpeciesResult: Result<[Species], Error>

        var fetchSpeciesDetailRequestCount = 0
        var fetchSpeciesDetailResult: Result<SpeciesDetail, Error>

        init(fetchFiltersResult: Result<FilterCollection, Error> = .failure(Error.noHandlerDefined),
             fetchSpeciesResult: Result<[Species], Error> = .failure(Error.noHandlerDefined),
             fetchSpeciesDetailResult:  Result<SpeciesDetail, Error> = .failure(Error.noHandlerDefined)
        ) {
            self.fetchFiltersResult = fetchFiltersResult
            self.fetchSpeciesResult = fetchSpeciesResult
            self.fetchSpeciesDetailResult = fetchSpeciesDetailResult
        }

        func fetchFilters() async throws -> FilterCollection {
            fetchFiltersRequestCount += 1
            return try fetchFiltersResult.get()
        }

        func fetchSpecies() async throws -> [Species] {
            fetchSpeciesRequestCount += 1
            return try fetchSpeciesResult.get()
        }

        func fetchSpeciesDetail(for speciesID: Int) async throws -> SpeciesDetail {
            fetchSpeciesDetailRequestCount += 1
            return try fetchSpeciesDetailResult.get()
        }
    }
}
