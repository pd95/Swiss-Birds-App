//
//  SpeciesDTO.swift
//  SpeciesCore
//
//  Created by Philipp on 22.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation

extension RemoteDataMapper {
    struct SpeciesDTO: Decodable {
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
}
