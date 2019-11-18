//
//  ContentView.swift
//  schweizer-voegel
//
//  Created by Philipp on 30.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            BirdList(species: allSpecies)
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .padding([.trailing])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
