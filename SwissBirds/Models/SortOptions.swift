//
//  SortOptions.swift
//  SwissBirds
//
//  Created by Philipp on 28.10.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation

struct SortOptions: CustomStringConvertible, Equatable {
    var column: SortColumn = .speciesName

    enum SortColumn: Equatable, Hashable, RawRepresentable, CaseIterable, CustomStringConvertible {

        case speciesName
        case filterType(FilterType)

        var description: String {
            switch self {
                case .speciesName:
                    return "Alphabetisch (name)"
                case .filterType(let type):
                    return type.rawValue
            }
        }

        // MARK: RawRepresentable
        typealias RawValue = String
        init?(rawValue: String) {
            if rawValue.hasPrefix("filter"), let filterType = FilterType(rawValue: rawValue) {
                self = .filterType(filterType)
            } else if rawValue == "speciesName" {
                self = .speciesName
            } else {
                return nil
            }
        }

        var rawValue: String {
            switch self {
                case .speciesName:
                    return "speciesName"
                case .filterType(let type):
                    return type.rawValue
            }
        }

        // MARK: CaseIterable
        static var allCases: [SortColumn] = {
            var allCases = [SortColumn]()

            allCases.append(.speciesName)
            allCases.append(.filterType(.vogelgruppe))
            FilterType.allCases.forEach { (type) in
                // Include only the filter types for which all birds have only a single value
                if ![.undefined, .lebensraum, .nahrung, .favorites].contains(type) {
                    let sortColumn = SortColumn.filterType(type)
                    if !allCases.contains(sortColumn) {
                        allCases.append(sortColumn)
                    }
                }
            }

            return allCases
        }()
    }

    var description: String {
        "SortOptions(column: \(column))"
    }
}
