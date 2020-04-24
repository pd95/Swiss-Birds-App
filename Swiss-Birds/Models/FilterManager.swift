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

    private func addFilter(_ filter: Filter) {
        if activeFilters[filter.type] == nil {
            activeFilters[filter.type] = [filter.filterId]
        }
        else {
            activeFilters[filter.type]!.append(filter.filterId)
        }
    }

    private func removeFilter(_ filter: Filter) {
        if let index = activeFilters[filter.type]?.firstIndex(of: filter.filterId)
            ,index >= 0 {
            activeFilters[filter.type]!.remove(at:index)
            if activeFilters[filter.type]!.isEmpty {
                activeFilters.removeValue(forKey: filter.type)
            }
        }
        else {
            print("removeFilter called without filter being selected!")
        }
    }

    /// Check whether a specific filter is set
    func hasFilter(_ filter: Filter) -> Bool {
        return activeFilters[filter.type]?.contains(filter.filterId) ?? false
    }

    /// Toggle (=add/remove) a specific filter
    func toggleFilter(_ filter: Filter) {
        if hasFilter(filter) {
            removeFilter(filter)
        }
        else {
            addFilter(filter)
        }
    }

    /// Check whether there is any filter at all
    func hasFilter() -> Bool {
        activeFilters.isEmpty
    }

    /// Remove all filters which have been set
    func clearFilters() {
        activeFilters.removeAll()
    }

    /// Returns the number of all species which would currently match the active filters
    func countMatches() -> Int {
        return allSpecies.filter {$0.categoryMatches(filters: activeFilters)}.count
    }
}
