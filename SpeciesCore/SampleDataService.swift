//
//  SampleDataService.swift
//  SpeciesCore
//
//  Created by Philipp on 10.03.23.
//  Copyright © 2023 Philipp. All rights reserved.
//

import Foundation

#if DEBUG
public struct SampleDataService: DataService {
    public init() {
    }

    public func fetchFilters() async throws -> FilterCollection {
        .example
    }

    public func fetchSpecies() async throws -> [Species] {
        Species.examples
    }

    public func fetchSpeciesDetail(for speciesID: Int) async throws -> SpeciesDetail {
        .example
    }
}
#endif
