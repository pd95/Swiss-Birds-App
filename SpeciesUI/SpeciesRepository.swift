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
            Self.logger.log("fetch species started")
            let species = try await self.service.fetchSpecies()
            Self.logger.log("fetch species done: \(species.count) fetched")

            self.species = species

            Self.logger.log("fetch filters started")
            let filters = try await self.service.fetchFilters()
            Self.logger.log("fetch filters done \(filters.allTypes.count) types fetched")

            self.filters = filters
        } catch {
            Self.logger.error(error.localizedDescription)
        }
    }
}
