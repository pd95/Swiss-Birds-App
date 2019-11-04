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
            SymbolView(symbolName: bird.groupImageName, pointSize: 24)
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
    @State private var filters = [Filter]()
    
    var body: some View {
        
        List {
            Section {
                SearchField(searchText: $searchText)
            }

            Section {
                ForEach(species.filter{$0.matchesSearch(for: searchText) && !(onlyCommon && !$0.isCommon)}) { bird in
                    NavigationLink(destination: BirdDetail(bird: bird)) {
                        BirdRow(bird: bird)
                    }
                }
            }
        }
        .navigationBarTitle(Text("Vögel der Schweiz"))
        .sheet(isPresented: $showFilters,
               onDismiss: { print(self.showFilters) },
               content: { FilterCriteria(filters: self.filters)})
        .navigationBarItems(
            trailing: Button(action: { self.showFilters = true },
                             label: { Image(systemName: onlyCommon ? "line.horizontal.3.decrease.circle.fill" : "line.horizontal.3.decrease.circle") }))
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
