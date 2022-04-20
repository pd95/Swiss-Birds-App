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

        let filters: [(type: String, filterIDs: String)]

        enum CodingKeys: String, CodingKey {
            case id = "artid"
            case name = "artname"
            case synonyms = "synonyme"
            case alias = "alias"
            case voiceData = "voice"
        }

        // CodingKeys which map all "filter" attributes
        struct FilterCodingKeys: CodingKey {
            var stringValue: String
            var intValue: Int?

            init?(stringValue: String) {
                guard stringValue.starts(with: "filter") else {
                    return nil
                }
                self.stringValue = stringValue
            }

            init?(intValue: Int) {
                return nil
            }
        }

        init(from decoder: Decoder) throws {
            // First decode the basic "Species data"
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            synonyms = try container.decode(String.self, forKey: .synonyms)
            alias = try container.decode(String.self, forKey: .alias)
            voiceData = try container.decode(String.self, forKey: .voiceData)

            // Then extract all the filters
            let filterContainer = try decoder.container(keyedBy: FilterCodingKeys.self)
            var filters = [(String,String)]()
            for key in filterContainer.allKeys {
                let filterIDs = try filterContainer.decode(String.self, forKey: key)

                let type = String(key.stringValue.dropFirst(6))
                filters.append((type, filterIDs))
            }
            self.filters = filters
        }
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
