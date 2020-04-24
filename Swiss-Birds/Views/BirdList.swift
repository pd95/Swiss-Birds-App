//
//  BirdList.swift
//  Swiss-Birds
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI


struct BirdList: View {

    var species: [Species]
    
    @EnvironmentObject private var state : AppState
    
    var body: some View {
        
        VStack {
            List {
                Section {
                    SearchField(searchText: $state.searchText)
                }

                Section {
                    ForEach(species.filter{$0.nameMatches(state.searchText) && $0.categoryMatches(filters: state.filterManager.activeFilters)}) { bird in
                        NavigationLink(destination: BirdDetail(bird: bird), tag: bird.speciesId, selection: self.$state.selectedBirdId) {
                            BirdRow(bird: bird)
                        }
                        .accessibility(identifier: "birdRow_\(bird.speciesId)")
                    }
                }
            }
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
                        Image(systemName: state.filterManager.activeFilters.count > 0 ? "line.horizontal.3.decrease.circle.fill" : "line.horizontal.3.decrease.circle")
                    }
                }
                .accessibility(identifier: "filterButton")
            )

            NavigationLink(destination: FilterCriteria(),
                           isActive: $state.showFilters) {
                            Text("*** never shown ***")
            }
            .frame(width: 0, height: 0)
            .hidden()

            // Workaround SwiftUI: when state is restored, the currently selected bird
            // can be at the bottom of the scrolling list. Therefore we add here an artificial row
            // which is already selected
            if state.restoredBirdId != nil {
                NavigationLink(destination: BirdDetail(bird: species.first { $0.speciesId == state.restoredBirdId! }!
                ), tag: state.restoredBirdId!, selection: self.$state.restoredBirdId) {
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
                BirdList(species: allSpecies)
            }
            ContentView()
                .environment(\.colorScheme, .dark)
        }
        .environmentObject(appState)
    }
}
