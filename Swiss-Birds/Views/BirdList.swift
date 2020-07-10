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
        // Define custom bindings to avoid "duplicate assignments" (which often causes navigation hick-ups)
        let selectedNavigationLinkBinding = Binding<MainNavigationLinkTarget?>(
            get: { self.state.selectedNavigationLink },
            set: { (newValue) in
                if self.state.selectedNavigationLink != newValue {
                    self.state.selectedNavigationLink = newValue
                }
        })

        return VStack(spacing: 0) {
            List {
                Section {
                    SearchField(searchText: $state.searchText, isEditing: $state.isEditingSearchField)
                        .autocapitalization(.words)
                }

                Section {
                    ForEach(state.matchingSpecies) { bird in
                        NavigationLink(destination: BirdDetailContainer(bird: bird),
                                       tag: MainNavigationLinkTarget.birdDetails(bird.speciesId),
                                       selection: selectedNavigationLinkBinding) {
                            BirdRow(bird: bird)
                        }
                        .accessibility(identifier: "birdRow_\(bird.speciesId)")
                    }
                }
            }
            .simultaneousGesture(DragGesture().onChanged({ (value: DragGesture.Value) in
                if self.state.isEditingSearchField {
                    print("Searching was enabled, but drag occured => endEditing")
                    self.state.isEditingSearchField = false
                    UIApplication.shared.endEditing()
                }
            }))
            .navigationBarTitle(Text("Vögel der Schweiz"))
            .navigationBarItems(
                trailing:
                Button(action: self.state.showFilter) {
                    HStack {
                        Text("Filter")
                        Image(systemName: state.filters.hasFilter() ? "line.horizontal.3.decrease.circle" : "line.horizontal.3.decrease.circle.fill")
                            .imageScale(.large)
                    }
                    .accessibilityElement(children: .combine)
                }
                .disabled(Filter.allFiltersGrouped.isEmpty)
                .accessibility(identifier: "filterButton")
            )

            if self.state.selectedNavigationLink != nil {
                dynamicNavigationLinkTarget
            }

/// 8< ----- Workaround broken SwiftUI end

        }
    }

    // Here we handle the dynamically generated links (filter list or restored bird selection)
    var dynamicNavigationLinkTarget: some View {
        let currentTag = self.state.selectedNavigationLink!
        let species: Species?
        if case .programmaticBirdDetails(let speciesId) = currentTag {
            species = Species.species(for: speciesId)!
        }
        else {
            species = nil
        }
        return Group {
            if currentTag == .filterList {
                NavigationLink(destination: FilterCriteria(managedList: self.state.filters),
                               tag: currentTag,
                               selection: self.$state.selectedNavigationLink) {
                                Text("*** never shown ***")
                }
                .frame(width: 0, height: 0)
                .hidden()
            }
            else if species != nil {
                NavigationLink(destination: BirdDetailContainer(bird: species!),
                               tag: currentTag,
                               selection: self.$state.selectedNavigationLink) {
                                Text("*** never shown ***")
                }
                .frame(width: 0, height: 0)
                .hidden()
            }
        }
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
