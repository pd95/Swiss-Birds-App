//
//  Filter.swift
//  Swiss-Birds
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

enum FilterType: String, CaseIterable, CustomStringConvertible {
    case haeufigeart = "filterhaeufigeart"
    case lebensraum = "filterlebensraum"
    case nahrung = "filternahrung"
    case roteListe = "filterrotelistech"
    case entwicklungatlas = "filterentwicklungatlas"
    case vogelgruppe = "filtervogelguppe"

    var shouldSortForDisplay : Bool {
        switch self {
            case .lebensraum, .nahrung, .vogelgruppe:
                return true
            default:
                return false
        }
    }

    var description: String {
        return "FilterType(\(self.rawValue))"
    }
}

struct Filter: Identifiable, Equatable, Hashable {
    typealias Id = Int

    let id = UUID()

    let filterId: Id
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

    static func filter(forId filterId: Id, ofType filterType: FilterType) -> Filter? {
        allFiltersGrouped[filterType]?.filter{$0.filterId == filterId}.first
    }

    static var commonBirds : Filter = {
        allFiltersGrouped[.haeufigeart]!.filter{ $0.filterId == 1 }.first!
    }()
}

typealias FilterList = [FilterType: [Filter.Id]]
