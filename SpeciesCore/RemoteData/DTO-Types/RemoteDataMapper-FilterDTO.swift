//
//  FilterDTO.swift
//  SpeciesCore
//
//  Created by Philipp on 22.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation

extension RemoteDataMapper {
    struct FilterDTO: Decodable {
        let type: String
        let filterId: String
        let filterName: String

        enum CodingKeys: String, CodingKey {
            case type
            case filterId = "filter_id"
            case filterName = "filter_name"
        }
    }
}
