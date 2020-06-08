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
        
        VStack {
            List {
                Section {
                    SearchField(searchText: $state.searchText, isEditing: $state.isEditingSearchField)
                }

                Section {
                    ForEach(state.matchingSpecies) { bird in
                        NavigationLink(destination: BirdDetailContainer(bird: bird, birdService: appState.birdService),
                                       tag: bird.speciesId, selection: self.$state.selectedBirdId) {
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
                    self.state.selectedBirdId = nil
                    self.state.showFilters = true
                    UIApplication.shared.endEditing()
                }) {
                    HStack {
                        Text("Filter")
                        Image(systemName: state.filters.hasFilter() ? "line.horizontal.3.decrease.circle" : "line.horizontal.3.decrease.circle.fill")
                    }
                }
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
            if restoredBird != nil {
                NavigationLink(destination: BirdDetailContainer(bird: restoredBird!, birdService: appState.birdService),
                               tag: state.restoredBirdId!, selection: self.$state.restoredBirdId) {
                    Text("*** never shown ***")
                }
                .hidden()
                .accessibility(identifier: "birdRow_restored")
            }

/// 8< ----- Workaround broken SwiftUI end

        }
    }

    var restoredBird: Species! {
        if let restoredBird = state.restoredBirdId {
            return self.state.allSpecies.first { $0.speciesId == restoredBird }
        }
        return nil
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
        .environmentObject(appState)
    }
}
