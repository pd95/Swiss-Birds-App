//
//  SortOptions.swift
//  Swiss-Birds
//
//  Created by Philipp on 28.10.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation

struct SortOptions: CustomStringConvertible, Equatable {
    var column: SortColumn = .speciesName

    enum SortColumn: String, Equatable, Codable, CaseIterable, CustomStringConvertible {
        case speciesName = "Artname"
        case groupName = "Vogel Gruppe"

        var description: String {
            self.rawValue
        }
    }

    var description: String {
        "SortOptions(column: \(column))"
    }
}
