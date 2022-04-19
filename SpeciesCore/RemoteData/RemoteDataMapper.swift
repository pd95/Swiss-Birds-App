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

    private struct FilterDTO: Decodable {
        let type: String
        let filterId: String
        let filterName: String

        enum CodingKeys: String, CodingKey {
            case type
            case filterId = "filter_id"
            case filterName = "filter_name"
        }
    }

    private struct SpeciesDTO: Decodable {
        let id: String
        let name: String
        let synonyms: String
        let alias: String
        let voiceData: String

        // TODO: Add support for filter values!

        enum CodingKeys: String, CodingKey {
            case id = "artid"
            case name = "artname"
            case synonyms = "synonyme"
            case alias = "alias"
            case voiceData = "voice"
        }
    }

    public static func mapFilter(_ data: Data) throws -> [Filter] {
        let filter = try JSONDecoder()
            .decode([FilterDTO].self, from: data)
            .map({ rawFilter in
                guard let filterID = Int(rawFilter.filterId) else {
                    throw Errors.invalidID(rawFilter.filterId)
                }
                return (FilterType.filterType(for: rawFilter.type), filterID, rawFilter.filterName)
            })
            .map(Filter.init)
        return filter
    }

    public static func mapSpecies(_ data: Data) throws -> [Species] {
        let species = try JSONDecoder()
            .decode([SpeciesDTO].self, from: data)
            .map({ raw -> Species in
                guard let speciesID = Int(raw.id) else {
                    throw Errors.invalidID(raw.id)
                }
                return Species(id: speciesID, name: raw.name, synonyms: raw.synonyms, alias: raw.alias, voiceData: raw.voiceData == "1")
            })
        return species
    }
}
