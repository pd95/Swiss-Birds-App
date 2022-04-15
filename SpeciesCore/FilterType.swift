//
//  FilterType.swift
//  SpeciesCore
//
//  Created by Philipp on 15.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation

public struct FilterType: Identifiable {
    public typealias ID = Int

    public let id: ID
    public let type: String
}

extension FilterType: Equatable {
    public static func == (lhs: FilterType, rhs: FilterType) -> Bool {
        lhs.id == rhs.id
    }
}

extension FilterType: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension FilterType: CustomStringConvertible {
    public var description: String {
        type
    }
}

extension FilterType {
    private static var allFilterTypes: [String: FilterType] = [:]
    public static func filterType(for name: String) -> FilterType {
        if let matchingFilter = allFilterTypes[name] {
            return matchingFilter
        }
        let newFilter = FilterType(id: nextID(), type: name)
        allFilterTypes[name] = newFilter
        return newFilter
    }

    private static var lastID: ID = 0
    private static func nextID() -> ID {
        lastID += 1
        return lastID
    }
}
