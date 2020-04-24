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
            NoFilterCheckButton(identifier: "noFiltering", text: "Keine Filter")
            FilterCheckButton(identifier: "onlyCommon", text: "Nur häufige Vögel", filter: self.filterManager.commonBirds)

            ForEach(FilterType.allCases.filter { $0 != .haeufigeart}, id: \.self) { filterType in
                Section(header:
                    Text(LocalizedStringKey(filterType.rawValue), comment: "FilterType description")
                        .accessibility(label: Text("Filtergruppe"))
                        .accessibility(value: Text(LocalizedStringKey(filterType.rawValue)))
                ) {
                    ForEach(Filter.allFiltersGrouped[filterType]!, id: \.self) { filter in
                        FilterCheckButton(filter: filter)
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

struct NoFilterCheckButton: View {
    @ObservedObject var filterManager = FilterManager.shared

    let identifier: String
    let text: String

    var body: some View {
        Button(action: { self.filterManager.clearFilters() }) {
            HStack {
                Checkmark(checked: filterManager.hasFilter())
                Text(text)
            }
        }
        .accessibility(identifier: identifier)
        .accessibility(addTraits: AccessibilityTraits(filterManager.hasFilter() ? [.isSelected] : []))
    }
}

struct FilterCheckButton: View {
    @ObservedObject var filterManager = FilterManager.shared

    let identifier: String
    let text: String
    let symbolName: String?
    let filter: Filter

    init(filter: Filter) {
        identifier = filter.uniqueFilterId
        text = filter.name
        symbolName = filter.uniqueFilterId
        self.filter = filter
    }

    init(identifier: String, text: String, filter: Filter) {
        self.identifier = identifier
        self.text = text
        self.symbolName = nil
        self.filter = filter
    }

    var accessibilityTraits : AccessibilityTraits {
        filterManager.hasFilter(filter) ? [.isSelected] : []
    }

    var body: some View {
        Button(action: { self.filterManager.toggleFilter(self.filter)}) {
            HStack {
                Checkmark(checked: filterManager.hasFilter(filter))
                if symbolName != nil {
                    SymbolView(symbolName: symbolName!)
                }
                Text(LocalizedStringKey(text))
            }
        }
        .accessibility(identifier: identifier)
        .accessibility(addTraits: AccessibilityTraits(filterManager.hasFilter(filter) ? [.isSelected] : []))
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
