//
//  ManagedFilterList.swift
//  Swiss-Birds
//
//  Created by Philipp on 24.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation

class ManagedFilterList: ObservableObject, CustomStringConvertible {

    private (set) var list: FilterList

    init(_ filterList: FilterList = [:]) {
        list = filterList
    }

    private func add(filter: Filter) {
        list[filter.type, default: []].append(filter.filterId)
    }

    private func remove(filter: Filter) {
        if let index = list[filter.type]?.firstIndex(of: filter.filterId),
           index >= 0 {
            list[filter.type]!.remove(at: index)
            if list[filter.type]!.isEmpty {
                list.removeValue(forKey: filter.type)
            }
        } else {
            print("removeFilter called without filter being selected!")
        }
    }

    /// Check whether a specific filter is set
    func contains(filter: Filter) -> Bool {
        return list[filter.type]?.contains(filter.filterId) ?? false
    }

    /// Toggle (=add/remove) a specific filter
    func toggle(filter: Filter) {
        objectWillChange.send()
        if contains(filter: filter) {
            remove(filter: filter)
        } else {
            add(filter: filter)
        }
    }

    /// Check whether there is any filter at all
    var isEmpty: Bool {
        list.isEmpty
    }

    /// Returns the number of enabled filters
    var count: Int {
        list.reduce(0) { (current, item) -> Int in
            current + item.value.count
        }
    }

    /// Remove all filters which have been set
    func removeAll() {
        objectWillChange.send()
        list.removeAll()
    }

    var description: String {
        return "ManagedFilterList(\(list))"
    }
}
