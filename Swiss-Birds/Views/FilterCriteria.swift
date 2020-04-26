//
//  FilterCriteria.swift
//  Swiss-Birds
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI

struct FilterCriteria: View {
    @EnvironmentObject private var state : AppState
    @ObservedObject var managedList : ManagedFilterList

    var body: some View {
        List {
            NoFilterCheckButton(identifier: "noFiltering", text: "Keine Filter")
            FilterCheckButton(identifier: "onlyCommon", text: "Nur häufige Vögel", filter: managedList.commonBirds)

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
        .environmentObject(managedList)
        .navigationBarTitle(Text("Filterkriterien (\(state.countFilterMatches()))"), displayMode: .inline)
    }
}

struct FilterCriteria_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FilterCriteria(managedList: ManagedFilterList())
                .environmentObject(appState)
        }
    }
}

struct NoFilterCheckButton: View {
    @EnvironmentObject var managedList: ManagedFilterList

    let identifier: String
    let text: String

    var body: some View {
        Button(action: { self.managedList.clearFilters() }) {
            HStack {
                Checkmark(checked: managedList.hasFilter())
                Text(LocalizedStringKey(text))
            }
        }
        .accessibility(identifier: identifier)
        .accessibility(addTraits: AccessibilityTraits(managedList.hasFilter() ? [.isSelected] : []))
    }
}

struct FilterCheckButton: View {
    @EnvironmentObject var managedList: ManagedFilterList

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
        managedList.hasFilter(filter) ? [.isSelected] : []
    }

    var body: some View {
        Button(action: { self.managedList.toggleFilter(self.filter)}) {
            HStack {
                Checkmark(checked: managedList.hasFilter(filter))
                if symbolName != nil {
                    SymbolView(symbolName: symbolName!)
                }
                Text(LocalizedStringKey(text))
            }
        }
        .accessibility(identifier: identifier)
        .accessibility(addTraits: AccessibilityTraits(managedList.hasFilter(filter) ? [.isSelected] : []))
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
