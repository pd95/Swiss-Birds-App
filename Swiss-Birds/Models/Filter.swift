//
//  Filter.swift
//  Swiss-Birds
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

enum FilterType: String, CaseIterable {
    case haeufigeart = "filterhaeufigeart"
    case lebensraum = "filterlebensraum"
    case nahrung = "filternahrung"
    case roteListe = "filterrotelistech"
    case entwicklungatlas = "filterentwicklungatlas"
    case vogelgruppe = "filtervogelguppe"
}

struct Filter: Identifiable, Equatable, Hashable {
    let id = UUID()

    let filterId: Int
    let name : String
    let type : FilterType

    var uniqueFilterId : String {
        get {
            return "\(type.rawValue)-\(filterId)"
        }
    }

    static let allFiltersGrouped: [FilterType: [Filter]] = loadFilterData()

    static var allFilters: [Filter] {
        allFiltersGrouped.reduce([]) { (array, filterGroup) -> [Filter] in
            let (_, values) = filterGroup
            return array + values
        }
    }

    static func filter(forId filterId: Int, ofType filterType: FilterType) -> Filter? {
        allFiltersGrouped[filterType]?.filter{$0.filterId == filterId}.first
    }
}
