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
            Text("Falls keine Liste sichtbar ist: von der linken Seite her wischen oder das Gerät um 90° drehen.")
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
