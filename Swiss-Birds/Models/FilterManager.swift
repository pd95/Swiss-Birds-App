//
//  FilterManager.swift
//  Swiss-Birds
//
//  Created by Philipp on 24.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation
import Combine

class FilterManager: ObservableObject {

    static let shared = FilterManager()

    private init() {
        commonBirds = Filter.allFiltersGrouped[.haeufigeart]!.filter{ $0.filterId == 1 }.first!
    }

    @Published var activeFilters = [FilterType:[Int]]()

    let commonBirds : Filter

    func addFilter(_ filter: Filter) {
        if activeFilters[filter.type] == nil {
            activeFilters[filter.type] = [filter.filterId]
        }
        else {
            activeFilters[filter.type]!.append(filter.filterId)
        }
    }

    func removeFilter(_ filter: Filter) {
        if let index = activeFilters[filter.type]?.firstIndex(of: filter.filterId)
            ,index >= 0 {
            activeFilters[filter.type]!.remove(at:index)
            if activeFilters[filter.type]!.count == 0 {
                activeFilters.removeValue(forKey: filter.type)
            }
        }
        else {
            print("removeFilter called without filter being selected!")
        }
    }

    func hasFilter(_ filter: Filter) -> Bool {
        return activeFilters[filter.type]?.contains(filter.filterId) ?? false
    }

    func toggleFilter(_ filter: Filter) {
        if hasFilter(filter) {
            removeFilter(filter)
        }
        else {
            addFilter(filter)
        }
    }

    func clearFilters() {
        activeFilters.removeAll()
    }

    func countMatches() -> Int {
        return allSpecies.filter {$0.categoryMatches(filters: activeFilters)}.count
    }
}
