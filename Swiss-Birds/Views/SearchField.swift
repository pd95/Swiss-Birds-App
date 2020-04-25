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
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .padding(4)
                    .accessibility(identifier: "magnifyingGlass")
                    .accessibility(hidden: true)

                TextField("Search", text: $searchText)
                    .padding(.vertical, 7)
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
                    .disableAutocorrection(true)
                    .accessibility(identifier: "searchText")
                    .accessibility(label: Text("Search"))
                    .accessibility(addTraits: .isSearchField)
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
