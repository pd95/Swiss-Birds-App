//
//  BirdGrid.swift
//  Swiss-Birds
//
//  Created by Philipp on 13.10.21.
//  Copyright © 2021 Philipp. All rights reserved.
//

import SwiftUI

struct BirdGrid: View {

    @EnvironmentObject private var state: AppState

    var body: some View {
        ScrollView {
            if #available(iOS 14.0, *) {
                Section {
                    SearchField(searchText: $state.searchText, isEditing: $state.isEditingSearchField.animation())
                        .autocapitalization(.words)
                }
                .padding()
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120, maximum: 200), alignment: .top)], alignment: .center, spacing: 10, pinnedViews: [.sectionHeaders]) {

                    ForEach(state.groups, id: \.self) { key in
                        Section(header: sectionHeader(for: key)) {
                            ForEach(state.groupedBirds[key]!) { bird in
                                Button {
                                    state.showBird(bird)
                                } label: {
                                    BirdCell(bird: bird, searchText: state.searchText)
                                }
                                .accessibility(identifier: "birdRow_\(bird.speciesId)")
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .simultaneousGesture(DragGesture().onChanged({ (_: DragGesture.Value) in
                    _ = print("simultaneousGesture DragGesture")
                    if state.isEditingSearchField {
                        print("Searching was enabled, but drag occurred => endEditing")
                        withAnimation {
                            state.isEditingSearchField = false
                            UIApplication.shared.endEditing()
                        }
                    }
                }))
                Text(" ")
            }
        }
    }

    func sectionHeader(for group: SectionGroup) -> some View {
        HStack {
            if group.id.hasPrefix("filter") {
                SymbolView(symbolName: group.id, pointSize: 24)
                    .padding(4)
            }
            if #available(iOS 14.0, *) {
                Text(LocalizedStringKey(group.name))
                    .textCase(nil)
            } else {
                Text(LocalizedStringKey(group.name))
            }
            Spacer()
        }
        .font(.headline)
        .padding(16)
        .background(
            Color(.tertiarySystemBackground)
                .opacity(0.8)
                .cornerRadius(8)
                .padding(.vertical, 4)
        )
        .accessibility(identifier: "section_\(group.id)")
    }
}

struct BirdGrid_Previews: PreviewProvider {
    static var previews: some View {
        BirdGrid()
            .environmentObject(AppState.shared)
            .environmentObject(FavoritesManager.shared)
    }
}
