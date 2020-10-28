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
            FilterCheckButton(identifier: "onlyCommon", text: "Nur häufige Vögel", filter: Filter.commonBirds)

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
        }
        .environmentObject(AppState.shared)
    }
}

struct NoFilterCheckButton: View {
    @EnvironmentObject var managedList: ManagedFilterList

    let identifier: String
    let text: String

    var body: some View {
        Button(action: { managedList.removeAll() }) {
            HStack {
                Checkmark(checked: managedList.isEmpty)
                Text(LocalizedStringKey(text))
            }
        }
        .accessibility(identifier: identifier)
        .accessibility(addTraits: AccessibilityTraits(managedList.isEmpty ? [.isSelected] : []))
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
        managedList.contains(filter: filter) ? [.isSelected] : []
    }

    var body: some View {
        Button(action: { managedList.toggle(filter: filter)}) {
            HStack {
                Checkmark(checked: managedList.contains(filter: filter))
                if let symbolName = symbolName {
                    SymbolView(symbolName: symbolName)
                }
                Text(LocalizedStringKey(text))
            }
        }
        .accessibility(identifier: identifier)
        .accessibility(addTraits: accessibilityTraits)
    }
}
