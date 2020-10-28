//
//  SortOptions.swift
//  Swiss-Birds
//
//  Created by Philipp on 28.10.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation

struct SortOptions: CustomStringConvertible {
    var column: SortColumn = .speciesName
    var direction: SortDirection = .ascending

    enum SortColumn: String, Codable, CaseIterable, CustomStringConvertible {
        case speciesName = "Artname"
        case groupName = "Vogel Gruppe"

        var description: String {
            self.rawValue
        }
    }

    enum SortDirection: Int, Codable, CaseIterable, CustomStringConvertible {
        case ascending = 0, descending = 1

        mutating func toggle() {
            self = self == .descending ? .ascending : .descending
        }

        var description: String {
            self == .ascending ? "Aufsteigend" : "Absteigend"
        }
    }

    var description: String {
        "SortOptions(column: \(column), direction: \(direction))"
    }
}
