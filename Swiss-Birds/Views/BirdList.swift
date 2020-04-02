//
//  BirdList.swift
//  Swiss-Birds
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI

struct BirdRow: View {
    var bird: Species
    
    func hasEntwicklungsAtlasSymbol() -> Bool {
        return bird.filterSymbolName(.entwicklungatlas).count > 0
    }
    
    var body: some View {
        HStack {
            Image("assets/\(bird.speciesId)")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.primary, lineWidth: 0.5))
                .shadow(radius: 4)
                .accessibility(hidden: true)
            Text(bird.name)
                .foregroundColor(.primary)
            Spacer()
            if hasEntwicklungsAtlasSymbol() {
                SymbolView(symbolName: bird.filterSymbolName(.entwicklungatlas), pointSize: 24)
                    .accessibility(hidden: true)
            }
            SymbolView(symbolName: bird.filterSymbolName(.vogelgruppe), pointSize: 24, color: .secondary)
                .accessibility(hidden: true)
        }
//        .accessibilityElement(children: .contain)
    }
}

struct SearchField: View {
    @Binding public var searchText : String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .accessibility(identifier: "Magnifying glass")
                .accessibility(hidden: true)

            TextField("Suche", text: $searchText)
                .foregroundColor(.primary)
                .disableAutocorrection(true)
                .accessibility(identifier: "searchText")
                .accessibility(label: Text("Search text"))

            Button(action: { self.searchText = "" }) {
                Image(systemName: "xmark.circle.fill")
                    .opacity(searchText == "" ? 0 : 1)
                    .accessibility(label: Text("Clear"))
            }
            .accessibility(identifier: "clearButton")
        }
        .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
        .foregroundColor(.secondary)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10.0)
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .contain)
        .accessibility(addTraits: .isSearchField)
    }
}


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
                    ForEach(species.filter{$0.nameMatches(state.searchText) && $0.categoryMatches(filters: state.selectedFilters)}) { bird in
                        NavigationLink(destination: BirdDetail(bird: bird), tag: bird.speciesId, selection: self.$state.selectedBird) {
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
                    self.state.selectedBird = nil
                    self.state.showFilters = true
                    UIApplication.shared.endEditing()
                }) {
                    HStack {
                        Text("Filter")
                        Image(systemName: state.selectedFilters.count > 0 ? "line.horizontal.3.decrease.circle.fill" : "line.horizontal.3.decrease.circle")
                    }
                }
                .accessibility(identifier: "filterButton")
            )

            NavigationLink(destination: FilterCriteria(filters: $state.selectedFilters),
                           isActive: $state.showFilters) {
                            Text("*** never shown ***")
            }
            .frame(width: 0, height: 0)
            .hidden()
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
