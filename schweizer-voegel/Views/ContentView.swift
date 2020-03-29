//
//  ContentView.swift
//  schweizer-voegel
//
//  Created by Philipp on 30.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var isPortrait : Bool = true
    
    var body: some View {
        NavigationView {
            BirdList(species: allSpecies)
            Text("Falls keine Liste sichtbar ist: von der linken Seite her wischen oder das Gerät um 90° drehen.")
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .padding([.trailing], isPortrait ? 1 : 0)  // This is an ugly hack: by adding non-zero padding we force the side-by-side view
        .onReceive(
            NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification, object: nil)) { notification in
                guard let device = notification.object as? UIDevice else {
                    return
                }
                self.isPortrait = device.orientation.isPortrait || device.orientation == .unknown
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
