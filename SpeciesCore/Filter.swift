//
//  Filter.swift
//  SpeciesCore
//
//  Created by Philipp on 15.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation

public struct Filter {
    public let id: Int
    public let name: String
    public let type: FilterType

    public init(type: FilterType, id: Int, name: String) {
        self.id = id
        self.name = name
        self.type = type
    }
}

extension Filter: Equatable, Hashable {
    public static func == (lhs: Filter, rhs: Filter) -> Bool {
        lhs.type == rhs.type && lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(id)
    }
}

extension Filter: CustomStringConvertible {
    public var description: String {
        "\(type.description): \(name)"
    }
}

