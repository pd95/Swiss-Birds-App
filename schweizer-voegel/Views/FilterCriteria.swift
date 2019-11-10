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
    
    func addFilter(_ filter: Filter) {
        if self.filters[filter.type] == nil {
            self.filters[filter.type] = [filter.filterId]
        }
        else {
            self.filters[filter.type]!.append(filter.filterId)
        }
    }

    func removeFilter(_ filter: Filter) {
        if let index = self.filters[filter.type]?.firstIndex(of: filter.filterId)
            ,index >= 0 {
            self.filters[filter.type]!.remove(at:index)
            if self.filters[filter.type]!.count == 0 {
                self.filters.removeValue(forKey: filter.type)
            }
        }
        else {
            print("removeFilter called without filter beeing selected!")
        }
    }

    func hasFilter(_ filter: Filter) -> Bool {
        return filters[filter.type]?.contains(filter.filterId) ?? false
    }
    
    func countMatches() -> Int {
        return allSpecies.filter {$0.matchesFilter(filters)}.count
    }

    var body: some View {
        List {
            Button(action: {
                print("Clearing filter")
                self.filters.removeAll()
            }) {
                HStack {
                    Image(systemName: filters.count == 0 ? "checkmark.circle" : "circle")
                    Text("Alle Vögel")
                }
            }
            
            ForEach(FilterType.allCases, id: \.self) { filterType in
                Section(header: Text(filterType.description)) {
                    ForEach(allFilters[filterType]!, id: \.self) { filter in
                        Button(action: {
                            print("Button \(filter.uniqueFilterId)")
                            if self.hasFilter(filter) {
                                self.removeFilter(filter)
                            }
                            else {
                                self.addFilter(filter)
                            }
                        }) {
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
        .navigationBarTitle(Text("Filterkriterien (\(countMatches()))"))
    }
}

struct FilterCriteria_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FilterCriteria(filters: .constant([:]))
        }
    }
}
