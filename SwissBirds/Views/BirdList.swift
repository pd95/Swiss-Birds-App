//
//  BirdList.swift
//  SwissBirds
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI

struct BirdList: View {

    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var favoritesManager: FavoritesManager

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section {
                    SearchField(searchText: $state.searchText, isEditing: $state.isEditingSearchField.animation())
                        .autocapitalization(.words)
                }

                ForEach(state.groups, id: \.self) { key in
                    Section(header: sectionHeader(for: key)) {
                        ForEach(state.groupedBirds[key]!) { bird in
                            Button {
                                state.showBird(bird)
                            } label: {
                                BirdRow(
                                    bird: bird,
                                    isFavorite: favoritesManager.isFavorite(species: bird),
                                    searchText: state.searchText,
                                    sortColumn: state.sortOptions.column
                                )
                            }
                            .accessibility(identifier: "birdRow_\(bird.speciesId)")
                        }
                    }
                }
                .id(state.listID)
            }
            .listStyle(PlainListStyle())
            .simultaneousGesture(DragGesture().onChanged({ (_: DragGesture.Value) in
                if state.isEditingSearchField {
                    print("Searching was enabled, but drag occurred => endEditing")
                    withAnimation {
                        state.isEditingSearchField = false
                        UIApplication.shared.endEditing()
                    }
                }
            }))
        }
    }

    func sectionHeader(for group: SectionGroup) -> some View {
        HStack {
            if group.id.hasPrefix("filter") {
                SymbolView(symbolName: group.id, pointSize: 24)
                    .padding(4)
            }
            Text(LocalizedStringKey(group.name))
                .textCase(nil)
        }
        .accessibility(identifier: "section_\(group.id)")
    }
}

struct BirdList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                BirdList()
            }
            ContentView()
                .environment(\.colorScheme, .dark)
        }
        .environmentObject(AppState.shared)
        .environmentObject(FavoritesManager.shared)
    }
}
