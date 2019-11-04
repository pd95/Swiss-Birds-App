//
//  FilterCriteria.swift
//  schweizer-voegel
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI

struct FilterCriteria: View {
    @State public var filters = [Filter]()

    var body: some View {
            List {
                ForEach(FilterType.allCases, id: \.self) { filterType in
                    Section(header: Text(filterType.description)) {
                        ForEach(allFilters.keys.filter({ (key) -> Bool in
                            key.hasPrefix(filterType.rawValue)
                        }).sorted(), id: \.self) { key in
                            Button(action: {
                                if let index = self.filters.firstIndex(of: allFilters[key]!)
                                    ,index >= 0 {
                                    print("Deselected \(key)")
                                    self.filters.remove(at:index)
                                }
                                else {
                                    print("Selected \(key)")
                                    self.filters.append(allFilters[key]!)
                                }
                            }) {
                                HStack {
                                    Image(systemName: self.filters.contains(allFilters[key]!) ? "checkmark.circle" : "circle")
                                    SymbolView(symbolName: key, pointSize: 24)
                                    Text(allFilters[key]?.name ?? "no name")
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Filterkriterien"))
    }
}

struct FilterCriteria_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FilterCriteria()
        }
    }
}
