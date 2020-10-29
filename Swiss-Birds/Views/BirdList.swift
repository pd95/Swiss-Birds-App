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
                    SearchField(searchText: $state.searchText, isEditing: $state.isEditingSearchField)
                        .autocapitalization(.words)
                }

                ForEach(state.groups, id: \.self) { key in
                    Section(header: sectionHeader(for: key)) {
                        ForEach(state.groupedBirds[key]!) { bird in
                            NavigationLink(destination: BirdDetailContainer(bird: bird),
                                           tag: MainNavigationLinkTarget.birdDetails(bird.speciesId),
                                           selection: state.selectedNavigationLinkBinding) {
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
                    state.isEditingSearchField = false
                    UIApplication.shared.endEditing()
                }
            }))

            if requiresDynamicNavigationLink {
                dynamicNavigationLinkTarget
            }
        }
    }

    // Depending on the action (click on "Filter") or state restoration we have to
    // "force" a navigation link being selected
    var requiresDynamicNavigationLink: Bool {
        switch state.selectedNavigationLink {
            case .none, .birdDetails:
                return false
            default:
                return true
        }
    }

    func sectionHeader(for key: String) -> some View {
        Group {
            if #available(iOS 14.0, *) {
                Text(LocalizedStringKey(key))
                    .textCase(nil)

            } else {
                Text(LocalizedStringKey(key))
            }
        }
    }

    // Here we create the dynamically navigation link (filter list or restored bird selection)
    var dynamicNavigationLinkTarget: some View {
        let currentTag = state.selectedNavigationLink!
        let species: Species?
        if case .programmaticBirdDetails(let speciesId) = currentTag {
            species = Species.species(for: speciesId)!
        }
        else {
            species = nil
        }

        // Create destination view
        let destination: some View = Group {
            if currentTag == .filterList {
                FilterCriteria(managedList: state.filters)
            }
            else if let species = species {
                BirdDetailContainer(bird: species)
            }
            else if currentTag == .sortOptions {
                SelectSortOptions(sorting: $state.sortOptions)
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
    }
}
