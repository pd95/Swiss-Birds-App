//
//  BirdList.swift
//  Swiss-Birds
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI

struct BirdList: View {

    @EnvironmentObject private var state: AppState

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
                                BirdRow(bird: bird, searchText: state.searchText)
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
            Text(" ")
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
