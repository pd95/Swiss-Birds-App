//
//  SpeciesRepository.swift
//  Swiss-Birds
//
//  Created by Philipp on 15.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation
import SpeciesCore

class SpeciesRepository: ObservableObject {

    static private var logger: Logger = Logger(
        subsystem: Bundle(for: SpeciesRepository.self).bundleIdentifier!,
        category: String(describing: SpeciesRepository.self)
    )

    @Published private(set) var species: [SpeciesCore.Species] = []
    @Published private(set) var filters = FilterCollection()

    private let service: any DataService

    init(service: any DataService) {
        self.service = service
    }

    func refreshSpecies() async {
        do {
            Self.logger.log("fetching species and filters")
            async let species = self.service.fetchSpecies()
            async let filters = self.service.fetchFilters()

            (self.species, self.filters) = try await (species, filters)

            Self.logger.log("fetch species done: \(self.species.count) fetched")
            Self.logger.log("fetch filters done: \(self.filters.allTypes.count) types fetched")
        } catch {
            Self.logger.error(error.localizedDescription)
        }
    }

    func fetchDetails(for speciesID: Species.ID) async throws -> SpeciesDetail {
        Self.logger.log("fetching details for species with ID \(speciesID)")
        let species = try await self.service.fetchSpeciesDetail(for: speciesID)
        Self.logger.log("fetching details done")
        return species
    }
}
