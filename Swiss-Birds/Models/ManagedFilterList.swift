//
//  ManagedFilterList.swift
//  Swiss-Birds
//
//  Created by Philipp on 24.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation

class ManagedFilterList: ObservableObject, CustomStringConvertible {

    private var _list: FilterList

    var list: FilterList { _list }

    lazy var commonBirds : Filter = {
        Filter.allFiltersGrouped[.haeufigeart]!.filter{ $0.filterId == 1 }.first!
    }()

    init(_ filterList: FilterList = [:]) {
        _list = filterList
    }

    private func addFilter(_ filter: Filter) {
        if _list[filter.type] == nil {
            _list[filter.type] = [filter.filterId]
        }
        else {
            _list[filter.type]!.append(filter.filterId)
        }
    }

    private func removeFilter(_ filter: Filter) {
        if let index = _list[filter.type]?.firstIndex(of: filter.filterId)
            ,index >= 0 {
            _list[filter.type]!.remove(at:index)
            if _list[filter.type]!.isEmpty {
                _list.removeValue(forKey: filter.type)
            }
        }
        else {
            print("removeFilter called without filter being selected!")
        }
    }

    /// Check whether a specific filter is set
    func hasFilter(_ filter: Filter) -> Bool {
        return _list[filter.type]?.contains(filter.filterId) ?? false
    }

    /// Toggle (=add/remove) a specific filter
    func toggleFilter(_ filter: Filter) {
        if hasFilter(filter) {
            removeFilter(filter)
        }
        else {
            addFilter(filter)
        }
        objectWillChange.send()
    }

    /// Check whether there is any filter at all
    func hasFilter() -> Bool {
        _list.isEmpty
    }

    /// Remove all filters which have been set
    func clearFilters() {
        _list.removeAll()
        objectWillChange.send()
    }

    /// Returns the number of all species which would currently match the active filters
    func countMatches() -> Int {
        return allSpecies.filter {$0.categoryMatches(filters: _list)}.count
    }

    var description: String {
        return "ManagedFilterList(\(_list))"
    }
}
