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
    case vogelgruppe = "filtervogelgruppe"
    case vogelstimme = "voice"
    case undefined

    var shouldSortForDisplay : Bool {
        switch self {
            case .lebensraum, .nahrung, .vogelgruppe:
                return true
            default:
                return false
        }
    }

    var description: String {
        return "FilterType(\(rawValue))"
    }

    var valuesShouldSortByID: Bool {
        switch self {
            case .roteListe, .entwicklungatlas:
                return true
            default:
                return false
        }
    }

    var isSelectable: Bool {
        self != .undefined
    }
}

struct Filter: Identifiable, Equatable, Hashable, Comparable {
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

    static var allFiltersGrouped: [FilterType: [Filter]] = [:]

    static var allFilters: [Filter] {
        allFiltersGrouped.reduce([]) { (array, filterGroup) -> [Filter] in
            let (_, values) = filterGroup
            return array + values
        }
    }

    static func filter(forId filterId: Id, ofType filterType: FilterType) -> Filter? {
        allFiltersGrouped[filterType]?.filter{$0.filterId == filterId}.first
    }

    static let undefined = Filter(filterId: 0, name: "Undefiniert", type: .undefined)

    static var commonBirds : Filter = {
        allFiltersGrouped[.haeufigeart]!.filter{ $0.filterId == 1 }.first!
    }()

    static var hasVoice : Filter = {
        allFiltersGrouped[.vogelstimme]!.filter{ $0.filterId == 1 }.first!
    }()

    // MARK: Comparable
    static func < (lhs: Filter, rhs: Filter) -> Bool {
        if lhs.type == rhs.type {
            if lhs.type.valuesShouldSortByID {
                return lhs.uniqueFilterId < rhs.uniqueFilterId
            }
            return lhs.name < rhs.name
        }
        else {
            return rhs.type == .undefined
        }
    }
}

typealias FilterList = [FilterType: [Filter.Id]]
