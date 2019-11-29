//
//  BirdList.swift
//  schweizer-voegel
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
            Text(bird.name)
                .foregroundColor(.primary)
            Spacer()
            if hasEntwicklungsAtlasSymbol() {
                SymbolView(symbolName: bird.filterSymbolName(.entwicklungatlas), pointSize: 24)
            }
            SymbolView(symbolName: bird.filterSymbolName(.vogelgruppe), pointSize: 24, color: .secondary)
        }
    }
}

struct SearchField: View {
    @Binding public var searchText : String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            
            TextField("Suche", text: $searchText) {
                UIApplication.shared.endEditing()
            }
            .foregroundColor(.primary)
            .disableAutocorrection(true)
            
            Button(action: {
                self.searchText = ""
            }) {
                Image(systemName: "xmark.circle.fill").opacity(searchText == "" ? 0 : 1)
            }
        }
        .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
        .foregroundColor(.secondary)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10.0)
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

                Button(action: { self.state.showFilters = true },
                       label: {
                        HStack {
                            Text("Filter")
                            Image(systemName: state.selectedFilters.count > 0 ? "line.horizontal.3.decrease.circle.fill" : "line.horizontal.3.decrease.circle")
                        } })
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
