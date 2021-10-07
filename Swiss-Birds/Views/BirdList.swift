//
//  BirdList.swift
//  Swiss-Birds
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI

struct BirdList: View {
    
    @EnvironmentObject private var state : AppState

    var body: some View {
        return VStack(spacing: 0) {
            List {
                Section {
                    SearchField(searchText: $state.searchText, isEditing: $state.isEditingSearchField.animation())
                        .autocapitalization(.words)
                }

                ForEach(state.groups, id: \.self) { key in
                    Section(header: sectionHeader(for: key)) {
                        ForEach(state.groupedBirds[key]!) { bird in
                            NavigationLink(
                                destination: BirdDetailContainer(model: state.currentBirdDetails, bird: bird),
                                tag: MainNavigationLinkTarget.birdDetails(bird.speciesId),
                                selection: state.selectedNavigationLinkBinding
                            ) {
                                BirdRow(bird: bird)
                            }
                            .accessibility(identifier: "birdRow_\(bird.speciesId)")
                        }
                    }
                }
                .id(state.listID)
            }
            .listStyle(PlainListStyle())
            .simultaneousGesture(DragGesture().onChanged({ (value: DragGesture.Value) in
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
        }
        .accessibility(identifier: "section_\(group.id)")
    }

    // Here we create the dynamic navigation link (filter list or restored bird selection)
    var dynamicNavigationLinkTarget: some View {
        var currentTag = state.selectedNavigationLink ?? .nothing
        switch currentTag {
        case .filterList, .sortOptions, .programmaticBirdDetails:
            break
        default:
            currentTag = .nothing
        }

        // Create destination view
        let destination: some View = Group {
            switch currentTag {
            case .filterList:
                FilterCriteria(managedList: state.filters)
            case .programmaticBirdDetails(let speciesId):
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
