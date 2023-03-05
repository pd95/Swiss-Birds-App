//
//  DataService.swift
//  SpeciesCore
//
//  Created by Philipp on 05.03.23.
//  Copyright © 2023 Philipp. All rights reserved.
//

import Foundation

public protocol DataService {
    /// Fetch `Filter`s from the corresponding filters endpoint
    func fetchFilters() async throws -> FilterCollection

    /// Fetch `Species`s from the corresponding list endpoint
    func fetchSpecies() async throws -> [Species]

    /// Fetch `SpeciesDetail`s from the corresponding list endpoint
    func fetchSpeciesDetail(for speciesID: Int) async throws -> SpeciesDetail
}
