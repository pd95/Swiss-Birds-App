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
            }
        }
        .navigationBarTitle(Text("Sortierung"), displayMode: .inline)
    }
}

struct SortOptions_Previews: PreviewProvider {
    @State static var sortOption = SortOptions()
    static var previews: some View {
        SelectSortOptions(sorting: $sortOption)
    }
}
