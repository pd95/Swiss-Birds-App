//
//  BirdGrid.swift
//  Swiss-Birds
//
//  Created by Philipp on 13.10.21.
//  Copyright © 2021 Philipp. All rights reserved.
//

import SwiftUI

struct BirdGrid: View {
    
    @EnvironmentObject private var state : AppState

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
                                BirdCell(bird: bird, searchText: state.searchText)
                                    .onTapGesture {
                                        state.selectedNavigationLinkBinding.wrappedValue = MainNavigationLinkTarget.birdDetails(bird.speciesId)
                                    }
                                    .accessibility(identifier: "birdRow_\(bird.speciesId)")
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .simultaneousGesture(DragGesture().onChanged({ (value: DragGesture.Value) in
                    let _ = print("simultaneousGesture DragGesture")
                    if state.isEditingSearchField {
                        print("Searching was enabled, but drag occurred => endEditing")
                        withAnimation {
                            state.isEditingSearchField = false
                            UIApplication.shared.endEditing()
                        }
                    }
                }))

                dynamicNavigationLinkTarget
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
            }
            else {
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

    // Here we create the dynamic navigation link (filter list or restored bird selection)
    var dynamicNavigationLinkTarget: some View {
        var currentTag = state.selectedNavigationLink ?? .nothing
        switch currentTag {
        case .filterList, .sortOptions, .programmaticBirdDetails, .birdDetails:
            break
        default:
            currentTag = .nothing
        }

        // Create destination view
        let destination: some View = Group {
            switch currentTag {
            case .filterList:
                FilterCriteria(managedList: state.filters)
            case .programmaticBirdDetails(let speciesId), .birdDetails(let speciesId):
                if let species = Species.species(for: speciesId) {
                    BirdDetailContainer(model: state.currentBirdDetails, bird: species)
                }
            case .sortOptions:
                SelectSortOptions(sorting: $state.sortOptions)
            default:
                EmptyView()
            }
        }

        // Create the NavigationLink
        return NavigationLink(destination: destination,
                              tag: currentTag,
                              selection: state.selectedNavigationLinkBinding) {
            Text("*** never shown ***")
        }
        .frame(width: 0, height: 0)
        .hidden()
    }
}

struct BirdGrid_Previews: PreviewProvider {
    static var previews: some View {
        BirdGrid()
            .environmentObject(AppState.shared)
            .environmentObject(FavoritesManager.shared)
    }
}
