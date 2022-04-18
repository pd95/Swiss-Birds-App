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

    public static func mapFilter(_ data: Data) throws -> [Filter] {
        do {
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
        } catch {
            throw error
        }
    }
}
