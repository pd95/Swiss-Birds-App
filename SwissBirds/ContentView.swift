//
//  ContentView.swift
//  SwissBirds
//
//  Created by Philipp on 06.03.23.
//  Copyright © 2023 Philipp. All rights reserved.
//

import SwiftUI
import SpeciesCore
import SpeciesUI

struct ContentView: View {
    @EnvironmentObject private var repository: SpeciesRepository
    @State private var search = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(repository.species.filter({ search.isEmpty || $0.name.localizedCaseInsensitiveContains(search)})) { species in
                    SpeciesListRow(species: species, filters: repository.filters)
                }
            }
            .searchable(text: $search)
            .listStyle(.inset)
            .navigationTitle("Swiss Birds")
        }
    }

    struct SpeciesListRow: View {

        let species: Species
        let filters: FilterCollection

        var body: some View {
            VStack(alignment: .leading) {
                Text(species.name)
                    .font(.headline)
                Text(Array(species.filters.map(\.localizedName)).sorted().joined(separator: ", "))
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    @State static private var repo = SpeciesRepository(service: SampleDataService())

    static var previews: some View {
        ContentView()
            .environmentObject(repo)
            .task { try? await repo.refreshSpecies() }
    }
}
#endif
