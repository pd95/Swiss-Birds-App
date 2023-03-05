//
//  FilterCollection.swift
//  SpeciesCore
//
//  Created by Philipp on 20.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation

public struct FilterCollection {
    var allFilters: [FilterType: [Filter]]

    public init() {
        allFilters = [:]
    }

    @discardableResult
    public mutating func addFilter(type: FilterType, id: Int, name: String) -> Filter {
        var filters = allFilters[type, default: []]
        let filter = Filter(type: type, id: id, name: name)
        if let index = filters.firstIndex(where: { $0.id == id }) {
            filters[index] = filter
        } else {
            filters.append(filter)
        }
        allFilters[type] = filters

        return filter
    }

    public var allTypes: Set<FilterType> {
        Set(allFilters.keys)
    }

    public func filters(for type: FilterType) -> [Filter] {
        allFilters[type, default: []]
    }

    public func filter(withID filterID: Filter.ID, for type: FilterType) -> Filter? {
        allFilters[type, default: []].first(where: { $0.id == filterID })
    }
}

#if DEBUG
extension FilterCollection {
    public static var example: FilterCollection = {
        var collection = FilterCollection()
        for filter in Filter.examples {
            collection.addFilter(type: filter.type, id: filter.id, name: filter.name ?? "(no name)")
        }
        return collection
    }()
}
#endif
