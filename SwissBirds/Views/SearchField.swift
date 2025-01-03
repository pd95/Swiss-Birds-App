//
//  SearchField.swift
//  SwissBirds
//
//  Created by Philipp on 03.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct SearchField: View {
    @Binding public var searchText: String

    @Binding public var isEditing: Bool
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
                    .padding(.trailing, 4)
                    .accessibility(identifier: "magnifyingGlass")
                    .accessibility(hidden: true)

                TextField("Search", text: $searchText)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 7)
                    .disableAutocorrection(true)
                    .accessibility(identifier: "searchText")
                    .accessibility(label: Text("Search"))
                    .accessibility(addTraits: .isSearchField)
                    .onTapGesture {
                        isEditing = true
                    }

                if !searchText.isEmpty {
                    Button(action: { withAnimation { searchText = "" }}) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                    }
                    .hoverEffect()
                    .accessibility(label: Text("Clear"))
                    .accessibility(identifier: "clearButton")
                }
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)

            if isEditing {
                Button(action: {
                    withAnimation {
                        isFocused = false
                        isEditing = false
                        searchText = ""
                    }
                }) {
                    Text("Cancel")
                }
                .hoverEffect()
                .accessibility(identifier: "cancelButton")
                .buttonStyle(BorderlessButtonStyle())
                .padding(.leading, 8)
                .transition(.move(edge: .trailing))
            }

        }
        .focused($isFocused)
        .onChange(of: isEditing) { newValue in
            if !isEditing && isFocused {
                isFocused = false
            }
        }
        .onChange(of: isFocused) { newValue in
            if newValue && !isEditing {
                withAnimation {
                    isEditing = true
                }
            }
        }
        .transition(.move(edge: .trailing))
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .contain)
        .accessibility(identifier: "searchBar")
    }
}

struct SearchField_Preview_Helper: View {
    @State var query: String
    @State var edit: Bool

    init(query: String, edit: Bool) {
        _query = State<String>(initialValue: query)
        _edit = State<Bool>(initialValue: edit)
    }

    var body: some View {
        VStack {
            SearchField(searchText: $query,
                        isEditing: $edit)
                .padding()

            Button(action: {
                withAnimation {
                    edit.toggle()
                }
            }) {
                Text(verbatim: "Toggle Edit")
            }
        }

    }
}

#Preview {
    VStack {
        SearchField_Preview_Helper(query: "", edit: false)
        Divider()
        SearchField_Preview_Helper(query: "Amsel Drossel", edit: false)
        Divider()
        SearchField_Preview_Helper(query: "Amsel Drossel", edit: true)
    }
}
