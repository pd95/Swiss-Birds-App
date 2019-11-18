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
            Image(String(bird.speciesId))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 3)
            Text(bird.name)
            Spacer()
            if hasEntwicklungsAtlasSymbol() {
                SymbolView(symbolName: bird.filterSymbolName(.entwicklungatlas), pointSize: 24)
            }
            SymbolView(symbolName: bird.filterSymbolName(.vogelgruppe), pointSize: 24)
        }
    }
}

struct SearchField: View {
    @Binding public var searchText : String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            
            TextField("Suche", text: $searchText, onEditingChanged: { isEditing in
            }, onCommit: {
                print("onCommit")
            })
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
    
    @State private var searchText = ""
    @State private var onlyCommon = false
    @State private var showFilters = false
    @State private var filters = [FilterType:[Int]]()
    
    var body: some View {
        
        VStack {
            List {
                Section {
                    SearchField(searchText: $searchText)
                }

                Section {
                    ForEach(species.filter{$0.matchesSearch(for: searchText) && $0.matchesFilter(self.filters)}) { bird in
                        NavigationLink(destination: BirdDetail(bird: bird)) {
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

                Button(action: { self.showFilters = true },
                       label: {
                        HStack {
                            Text("Filter")
                            Image(systemName: self.filters.count > 0 ? "line.horizontal.3.decrease.circle.fill" : "line.horizontal.3.decrease.circle")
                        } })
            )

            NavigationLink(destination: FilterCriteria(filters: self.$filters),
                           isActive: $showFilters) {
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
    }
}
