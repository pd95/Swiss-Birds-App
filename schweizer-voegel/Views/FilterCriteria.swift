//
//  FilterCriteria.swift
//  schweizer-voegel
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI

struct FilterCriteria: View {
    var body: some View {
            List {
                ForEach(FilterType.allCases, id: \.self) { filterType in
                    Section(header: Text(filterType.description)) {
                        ForEach(filter.keys.filter({ (key) -> Bool in
                            key.hasPrefix(filterType.rawValue)
                        }).sorted(), id: \.self) { key in
                            HStack {
                                SymbolView(symbolName: key, pointSize: 24)
                                Text(filter[key]?.name ?? "no name")
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
