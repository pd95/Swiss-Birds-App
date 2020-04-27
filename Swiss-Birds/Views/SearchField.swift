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

    @Binding public var isEditing : Bool

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .padding(4)
                    .accessibility(identifier: "magnifyingGlass")
                    .accessibility(hidden: true)

                TextField("Search", text: $searchText)
                    .padding(.vertical, 7)
                    .disableAutocorrection(true)
                    .accessibility(identifier: "searchText")
                    .accessibility(label: Text("Search"))
                    .accessibility(addTraits: .isSearchField)
                    .overlay(
                        Group {
                            if isEditing && !searchText.isEmpty {
                                Button(action: { self.searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                                .padding(4)
                                .accessibility(label: Text("Clear"))
                                .accessibility(identifier: "clearButton")
                            }
                        },
                        alignment: .trailing
                    )
                    .onTapGesture {
                        self.isEditing = true
                    }
            }
            .padding(.horizontal, 4)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)

            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.searchText = ""
                    UIApplication.shared.endEditing()
                }) {
                    Text("Cancel")
                }
                .accessibility(identifier: "cancelButton")
                .buttonStyle(BorderlessButtonStyle())
                .padding(.leading, 4)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }

        }
        .transition(.move(edge: .trailing))
        .animation(.default)
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .contain)
        .accessibility(identifier: "searchBar")
    }
}


struct SearchField_Previews: PreviewProvider {
    static var previews: some View {
        var query = "Hallo"
        return Group {
            SearchField(searchText: Binding<String>(get: {query}, set: {query=$0}),
                        isEditing: .constant(true))
                .padding(.horizontal, 10)
                .previewLayout(.fixed(width: 400, height: 70))
        }
    }
}
