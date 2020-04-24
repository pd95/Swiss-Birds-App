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

    @State private var isEditing = false

    var body: some View {
        HStack {
            TextField("Suche", text: $searchText)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                            .accessibility(identifier: "magnifyingGlass")
                            .accessibility(hidden: true)

                        if isEditing && !searchText.isEmpty {
                            Button(action: { self.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, 8)
                                    .accessibility(label: Text("Clear"))
                            }
                            .accessibility(identifier: "clearButton")
                        }
                    }
                )
                .onTapGesture {
                    self.isEditing = true
                }
                .disableAutocorrection(true)
                .accessibility(identifier: "searchText")
                .accessibility(label: Text("Search text"))

            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.searchText = ""
                    UIApplication.shared.endEditing()
                }) {
                    Text("Cancel")
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.leading, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }

        }
        .transition(.move(edge: .trailing))
        .animation(.default)
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .contain)
        .accessibility(addTraits: .isSearchField)
    }
}


struct SearchField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SearchField(searchText: .constant("Hallo"))
                .padding(.horizontal, 10)
        }
    }
}
