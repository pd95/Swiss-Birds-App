//
//  RemoteDataMapper-FilterCodingKeys.swift
//  SpeciesCore
//
//  Created by Philipp on 22.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation

extension RemoteDataMapper {
    // CodingKeys which map attributes starting with "filter"
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
}
