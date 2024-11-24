//
//  SelectSortOptions.swift
//  SwissBirds
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
                Section(header: Text("Gruppierung")) {
                    ForEach(SortOptions.SortColumn.allCases, id: \.self) { column in
                        Button(action: { sorting.column = column }) {
                            HStack {
                                Checkmark(checked: sorting.column == column)
                                Text(LocalizedStringKey(column.description))
                            }
                        }
                        .accessibility(identifier: column.rawValue)
                    }
                }
            }
        }
        .navigationBarTitle(Text("Anordnung"), displayMode: .inline)
    }
}

#Preview {
    SelectSortOptions(sorting: .constant(SortOptions(column: .filterType(.vogelgruppe))))
}
