//
//  SpeciesRepository.swift
//  Swiss-Birds
//
//  Created by Philipp on 15.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation
import SpeciesCore

public class SpeciesRepository: ObservableObject {

    static private var logger: Logger = Logger(
        subsystem: Bundle(for: SpeciesRepository.self).bundleIdentifier!,
        category: String(describing: SpeciesRepository.self)
    )

    @Published public private(set) var species: [Species] = []
    @Published public private(set) var filters = FilterCollection()

    private let service: any DataService

    public init(service: any DataService) {
        self.service = service
    }

    public func refreshSpecies() async throws {
        do {
            Self.logger.log("fetching species and filters")
            async let species = self.service.fetchSpecies()
            async let filters = self.service.fetchFilters()

            await update(try await (species, filters))

            Self.logger.log("fetch species done: \(self.species.count) fetched")
            Self.logger.log("fetch filters done: \(self.filters.allTypes.count) types fetched")
        } catch {
            Self.logger.error(error.localizedDescription)
            throw error
        }
    }

    @MainActor
    private func update(_ tuple: (species: [Species], filters: FilterCollection)) {
        var tuple = tuple
        tuple.filters.addFilter(type: "haeufigeart", id: 0, name: "rare kind")
        tuple.filters.addFilter(type: "haeufigeart", id: 1, name: "common kind")
        (self.species, self.filters) = tuple
   }

    public func fetchDetails(for speciesID: Species.ID) async throws -> SpeciesDetail {
        Self.logger.log("fetching details for species with ID \(speciesID)")
        let species = try await self.service.fetchSpeciesDetail(for: speciesID)
        Self.logger.log("fetching details done")
        return species
    }
}
