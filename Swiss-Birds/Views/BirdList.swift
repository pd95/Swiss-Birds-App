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
        let selectedBirdIdBinding = Binding<Species.Id?>(
            get: { self.state.selectedBirdId },
            set: { (newValue) in
                if self.state.selectedBirdId != newValue {
                    self.state.selectedBirdId = newValue
                }
        })

        let restoredBirdIdBinding = Binding<Species.Id?>(
            get: { self.state.restoredBirdId },
            set: { (newValue) in
                if self.state.restoredBirdId != newValue {
                    self.state.restoredBirdId = newValue
                }
        })

        return VStack(spacing: 0) {
            List {
                Section {
                    SearchField(searchText: $state.searchText, isEditing: $state.isEditingSearchField)
                }

                Section {
                    ForEach(state.matchingSpecies) { bird in
                        NavigationLink(destination: BirdDetailContainer(bird: bird),
                                       tag: bird.speciesId,
                                       selection: selectedBirdIdBinding) {
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
/// 8< ----- Workaround broken SwiftUI: NavigationLink cannot be child of .navigationBarItems()
//                NavigationLink(destination: FilterCriteria(filters: self.$filters)) {
//                                Text("Filter")
//                }

                Button(action: {
                    // Erase selected bird and show the filters
                    self.state.showFilters = true
                    UIApplication.shared.endEditing()
                }) {
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

            NavigationLink(destination: FilterCriteria(managedList: self.state.filters),
                           isActive: $state.showFilters) {
                            Text("*** never shown ***")
            }
            .frame(width: 0, height: 0)
            .hidden()

            // Workaround SwiftUI: when state is restored, the currently selected bird
            // can be at the bottom of the scrolling list. Therefore we add here an artificial row
            // which is already selected
            if self.state.restoredBirdId != nil {
                NavigationLink(destination: BirdDetailContainer(bird: Species.species(for: self.state.restoredBirdId!)!),
                               tag: state.restoredBirdId!, selection: restoredBirdIdBinding) {
                    Text("*** never shown ***")
                }
                .hidden()
                .accessibility(identifier: "birdRow_restored")
            }

/// 8< ----- Workaround broken SwiftUI end

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
