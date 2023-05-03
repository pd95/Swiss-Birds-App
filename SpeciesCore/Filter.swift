//
//  Filter.swift
//  SpeciesCore
//
//  Created by Philipp on 15.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation

public struct Filter {
    public typealias ID = Int

    public let id: ID
    public let name: String?
    public let type: FilterType

    public let uniqueID: String

    public init(type: FilterType, id: Int, name: String? = nil) {
        self.id = id
        self.uniqueID = "\(type.id):\(id)"
        self.name = name ?? "\(type.id):\(id)"
        self.type = type
    }

    public var localizedName: String {
        name ?? uniqueID
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
        "\(type): \(name ?? String(id))"
    }
}

#if DEBUG
extension Filter {
    public static let examples: [Filter] = [
        Filter(type: "filterlebensraum", id: 1, name: "rocky terrain"),
        Filter(type: "filterlebensraum", id: 2, name: "wetlands"),
        Filter(type: "filterlebensraum", id: 3, name: "rivers & streams"),
        Filter(type: "filterlebensraum", id: 4, name: "alpine habitats"),
        Filter(type: "filterlebensraum", id: 5, name: "forest"),
        Filter(type: "filterlebensraum", id: 6, name: "wasteland"),
        Filter(type: "filterlebensraum", id: 7, name: "semi-open farmland"),
        Filter(type: "filterlebensraum", id: 8, name: "farmland"),
        Filter(type: "filterlebensraum", id: 9, name: "meadows and pastures"),
        Filter(type: "filterlebensraum", id: 10, name: "settlements"),
        Filter(type: "filternahrung", id: 1, name: "carcasses"),
        Filter(type: "filternahrung", id: 2, name: "rubbish"),
        Filter(type: "filternahrung", id: 3, name: "omnivore"),
        Filter(type: "filternahrung", id: 4, name: "amphibians"),
        Filter(type: "filternahrung", id: 5, name: "insects and spiders"),
        Filter(type: "filternahrung", id: 6, name: "seeds"),
        Filter(type: "filternahrung", id: 7, name: "fruits"),
        Filter(type: "filternahrung", id: 8, name: "fish"),
        Filter(type: "filternahrung", id: 9, name: "mammals"),
        Filter(type: "filternahrung", id: 10, name: "plants"),
        Filter(type: "filternahrung", id: 11, name: "other aquatic animals"),
        Filter(type: "filternahrung", id: 12, name: "reptiles"),
        Filter(type: "filternahrung", id: 13, name: "snails"),
        Filter(type: "filternahrung", id: 14, name: "birds"),
        Filter(type: "filternahrung", id: 15, name: "earthworms"),
    ]
}
#endif
