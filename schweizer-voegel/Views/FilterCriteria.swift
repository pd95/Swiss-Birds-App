//
//  FilterCriteria.swift
//  schweizer-voegel
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI

struct FilterCriteria: View {
    @Binding public var filters : [FilterType:[Int]]
    
    private let commonBirds = allFilters[.haeufigeart]!.filter{ $0.filterId == 1 }.first!
    

    func addFilter(_ filter: Filter) {
        if filters[filter.type] == nil {
            filters[filter.type] = [filter.filterId]
        }
        else {
            filters[filter.type]!.append(filter.filterId)
        }
    }

    func removeFilter(_ filter: Filter) {
        if let index = filters[filter.type]?.firstIndex(of: filter.filterId)
            ,index >= 0 {
            filters[filter.type]!.remove(at:index)
            if filters[filter.type]!.count == 0 {
                filters.removeValue(forKey: filter.type)
            }
        }
        else {
            print("removeFilter called without filter beeing selected!")
        }
    }

    func hasFilter(_ filter: Filter) -> Bool {
        return filters[filter.type]?.contains(filter.filterId) ?? false
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
        filters.removeAll()
    }
    
    func countMatches() -> Int {
        return allSpecies.filter {$0.categoryMatches(filters: filters)}.count
    }

    var body: some View {
        List {
            Button(action: { self.clearFilters() }) {
                HStack {
                    Image(systemName: filters.count == 0 ? "checkmark.circle" : "circle")
                    Text("Alle Vögel")
                }
            }
            
            Button(action: { self.toggleFilter(self.commonBirds) }) {
                HStack {
                    Image(systemName: self.hasFilter(commonBirds) ? "checkmark.circle" : "circle")
                    Text("Nur häufige Vögel")
                }
            }

            ForEach(FilterType.allCases.filter { $0 != .haeufigeart}, id: \.self) { filterType in
                Section(header: Text(filterType.description)) {
                    ForEach(allFilters[filterType]!, id: \.self) { filter in
                        Button(action: { self.toggleFilter(filter)}) {
                            HStack {
                                Image(systemName: self.hasFilter(filter) ? "checkmark.circle" : "circle")
                                SymbolView(symbolName: filter.symbolName)
                                Text(filter.name)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle(Text("Filterkriterien (\(countMatches()))"), displayMode: .inline)
    }
}

struct FilterCriteria_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FilterCriteria(filters: .constant([:]))
        }
    }
}
