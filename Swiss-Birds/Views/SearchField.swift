//
//  SearchField.swift
//  Swiss-Birds
//
//  Created by Philipp on 03.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct SearchField: View {
    @Binding public var searchText : String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .accessibility(identifier: "Magnifying glass")
                .accessibility(hidden: true)

            TextField("Suche", text: $searchText)
                .foregroundColor(.primary)
                .disableAutocorrection(true)
                .accessibility(identifier: "searchText")
                .accessibility(label: Text("Search text"))

            Button(action: { self.searchText = "" }) {
                Image(systemName: "xmark.circle.fill")
                    .opacity(searchText == "" ? 0 : 1)
                    .accessibility(label: Text("Clear"))
            }
            .accessibility(identifier: "clearButton")
        }
        .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
        .foregroundColor(.secondary)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10.0)
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .contain)
        .accessibility(addTraits: .isSearchField)
    }
}


struct SearchField_Previews: PreviewProvider {
    static var previews: some View {
        SearchField(searchText: .constant(""))
    }
}
