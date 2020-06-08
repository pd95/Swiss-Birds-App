//
//  ContentView.swift
//  Swiss-Birds
//
//  Created by Philipp on 30.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var state : AppState
    @State var isPortrait : Bool = true
    
    var body: some View {
        NavigationView {
            if state.allSpecies.count > 0 && Filter.allFiltersGrouped.count > 0 {
                BirdList()
            }
            else {
                ActivityIndicatorView()
            }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .padding([.trailing], isPortrait ? 1 : 0)  // This is an ugly hack: by adding non-zero padding we force the side-by-side view
        .onReceive(
            NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification, object: nil)) { notification in
                guard let device = notification.object as? UIDevice else {
                    return
                }
                self.isPortrait = device.orientation == .unknown ||
                    device.orientation.isPortrait && (
                        device.orientation != .faceUp ||
                        device.orientation != .faceDown
                    )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
