//
//  FilterCriteria.swift
//  Swiss-Birds
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI

struct FilterCriteria: View {
    @ObservedObject var filterManager = FilterManager.shared

    var body: some View {
        List {
            Button(action: { self.filterManager.clearFilters() }) {
                HStack {
                    Checkmark(checked: filterManager.activeFilters.count == 0)
                    Text("Keine Filter")
                }
            }
            .accessibility(identifier: "noFiltering")
//            .accessibility(addTraits: filters.count == 0 ? .isSelected)

            Button(action: { self.filterManager.toggleFilter(self.filterManager.commonBirds) }) {
                HStack {
                    Checkmark(checked: self.filterManager.hasFilter(self.filterManager.commonBirds))
                    Text("Nur häufige Vögel")
                }
            }
            .accessibility(identifier: "onlyCommon")

            ForEach(FilterType.allCases.filter { $0 != .haeufigeart}, id: \.self) { filterType in
                Section(header: Text(LocalizedStringKey(filterType.rawValue), comment: "FilterType description")) {
                    ForEach(Filter.allFiltersGrouped[filterType]!, id: \.self) { filter in
                        Button(action: { self.filterManager.toggleFilter(filter)}) {
                            HStack {
                                Checkmark(checked: self.filterManager.hasFilter(filter))
                                SymbolView(symbolName: filter.uniqueFilterId)
                                Text(filter.name)
                            }
                        }
                        .accessibility(identifier: filter.uniqueFilterId)
                    }
                }
            }
        }
        .navigationBarTitle(Text("Filterkriterien (\(filterManager.countMatches()))"), displayMode: .inline)
    }
}

struct FilterCriteria_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FilterCriteria()
        }
    }
}

struct Checkmark: View {
    var checked = true
    
    let checkmark = Image(systemName: "checkmark")
    
    var body: some View {
        Group {
            if checked {
                checkmark
            }
            else {
                checkmark.hidden()
            }
        }
    }
}
