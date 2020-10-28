//
//  SelectSortOptions.swift
//  Swiss-Birds
//
//  Created by Philipp on 28.10.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct SelectSortOptions: View {

    @Binding var sorting: SortOptions

    var body: some View {
        Form {
            List {
                Section(header: Text("Sortiere nach")) {
                    ForEach(SortOptions.SortColumn.allCases, id: \.self) { column in
                        Button(action: { sorting.column = column }) {
                            HStack {
                                Checkmark(checked: sorting.column == column)
                                Text(LocalizedStringKey(column.description))
                            }
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())

                Picker("Sortierung", selection: $sorting.direction) {
                    ForEach(SortOptions.SortDirection.allCases, id: \.self) { direction in
                        Text(direction.description)
                            .tag(direction.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .navigationBarTitle(Text("Sortierung"), displayMode: .inline)
    }

    var sortOrderButton: some View {
        Button(action: {
            withAnimation {
                sorting.direction.toggle()
            }
        }, label: {
            HStack {
                Text(LocalizedStringKey(sorting.direction.description))
                Image(systemName: "line.horizontal.3.decrease.circle")
                    .rotationEffect(sorting.direction == .ascending ? .degrees(180) : .zero)
                    .animation(.linear)
            }
        })
    }
}

struct SortOptions_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SelectSortOptions(sorting: .constant(.init()))
        }
    }
}
