//
//  RemoteDataService.swift
//  SpeciesCore
//
//  Created by Philipp on 15.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation

public struct RemoteDataService: DataService {

    public static let supportedLanguages: [String] = ["de", "fr", "it", "en"]

    let dataClient: DataClient
    let baseURL: URL
    let language: String

    public init(dataClient: DataClient, baseURL: URL = URL(string: "https://www.vogelwarte.ch")!, language: String = "en") {
        guard Self.supportedLanguages.contains(language) else {
            fatalError("Language \(language) is not supported. Use one of \(Self.supportedLanguages)")
        }

        self.dataClient = dataClient
        self.baseURL = baseURL
        self.language = language
    }

    // MARK: - Services

    /// Fetch `Filter`s from the corresponding filters endpoint
    public func fetchFilters() async throws -> FilterCollection {
        let url = baseURL.appendingPathComponent("/elements/snippets/vds/static/assets/data/filters_\(language).json")
        let (data, _) = try await dataClient.data(from: url)
        let filters: FilterCollection = try RemoteDataMapper.mapFilter(data)
        return filters
    }

    /// Fetch `Species`s from the corresponding list endpoint
    public func fetchSpecies() async throws -> [Species] {
        let url = baseURL.appendingPathComponent("/elements/snippets/vds/static/assets/data/list_\(language).json")
        let (data, _) = try await dataClient.data(from: url)
        let species: [Species] = try RemoteDataMapper.mapSpecies(data)
        return species
    }

    /// Fetch `SpeciesDetail`s from the corresponding list endpoint
    public func fetchSpeciesDetail(for speciesID: Int) async throws -> SpeciesDetail {
        let url = baseURL.appendingPathComponent("/elements/snippets/vds/static/assets/data/species/\(speciesID)_\(language).json")
        let (data, _) = try await dataClient.data(from: url)
        let details: SpeciesDetail = try RemoteDataMapper.mapSpeciesDetail(data, language: language)
        return details
    }
}
