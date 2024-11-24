//
//  BirdGrid.swift
//  SwissBirds
//
//  Created by Philipp on 13.10.21.
//  Copyright © 2021 Philipp. All rights reserved.
//

import SwiftUI

struct BirdGrid: View {

    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var favoritesManager: FavoritesManager

    var body: some View {
        ScrollView {
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
                                BirdCell(
                                    bird: bird,
                                    isFavorite: favoritesManager.isFavorite(species: bird),
                                    searchText: state.searchText
                                )
                            }
                            .accessibility(identifier: "birdRow_\(bird.speciesId)")
                        }
                    }
                }
            }
            .padding(.horizontal)
            .simultaneousGesture(DragGesture().onChanged({ (_: DragGesture.Value) in
                if state.isEditingSearchField {
                    print("Searching was enabled, but drag occurred => endEditing")
                    withAnimation {
                        state.stopEditing()
                    }
                }
            }))
        }
    }

    func sectionHeader(for group: SectionGroup) -> some View {
        HStack {
            if group.id.hasPrefix("filter") {
                SymbolView(symbolName: group.id)
                    .padding(4)
            }
            Text(LocalizedStringKey(group.name))
                .textCase(nil)
            Spacer()
        }
        .font(.title3.bold())
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

#Preview {
    BirdGrid()
        .environmentObject(AppState.shared)
        .environmentObject(FavoritesManager.shared)
}
