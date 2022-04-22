//
//  RemoteDataMapper.swift
//  SpeciesCore
//
//  Created by Philipp on 16.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation

public enum RemoteDataMapper {

    enum Errors: Error {
        case invalidID(String)
    }

    public static func mapFilter(_ data: Data) throws -> FilterCollection {
        let filter = try JSONDecoder()
            .decode([FilterDTO].self, from: data)
            .map({ rawFilter in
                guard let filterID = Int(rawFilter.filterId) else {
                    throw Errors.invalidID(rawFilter.filterId)
                }
                return (type: FilterType(rawFilter.type), id: filterID, name: rawFilter.filterName)
            })
            .reduce(into: FilterCollection(), { (filters: inout FilterCollection, filter: (type: FilterType, id: Int, name: String)) in
                filters.addFilter(type: filter.type, id: filter.id, name: filter.name)
            })
        return filter
    }

    public static func mapSpecies(_ data: Data) throws -> [Species] {
        let species = try JSONDecoder()
            .decode([SpeciesDTO].self, from: data)
            .map({ raw -> Species in
                guard let speciesID = Int(raw.id) else {
                    throw Errors.invalidID(raw.id)
                }

                var filters = Set<Filter>()
                for (type, filterIDsString) in raw.filters {
                    let filterIDs = filterIDsString.split(separator: ",").compactMap({ Int($0) })
                    for id in filterIDs {
                        filters.insert(Filter(type: FilterType(type), id: id, name: nil))
                    }
                }

                return Species(id: speciesID, name: raw.name, synonyms: raw.synonyms, alias: raw.alias, voiceData: raw.voiceData == "1", filters: filters)
            })
        return species
    }
}
