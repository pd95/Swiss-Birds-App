//
//  ContentView.swift
//  Swiss-Birds
//
//  Created by Philipp on 30.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Combine
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var state : AppState

    @State private var isPortrait : Bool = true

    var body: some View {
        ZStack {
            NavigationView {
                if state.initialLoadRunning {
                    ActivityIndicatorView()
                        .zIndex(1)
                }
                else {
                    BirdList()
                        .edgesIgnoringSafeArea(.bottom)
                        .zIndex(2)
                }
            }
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
            .padding([.trailing], isPortrait ? 1 : 0)  // This is an ugly hack: by adding non-zero padding we force the side-by-side view
            .accessibilityElement(children: state.showBirdOfTheDay ? .ignore : .contain)
            .accessibility(hidden: state.showBirdOfTheDay)

            if state.showBirdOfTheDay {
                // Dimmed background
                Color(.systemBackground)
                    .opacity(0.6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            state.showBirdOfTheDay = false
                        }
                    }
                    .accessibility(label: Text("Hintergrund"))
                    .accessibility(hint: Text("Antippen zum schliessen."))
                    .zIndex(10)
                    .accessibility(sortPriority: 990)
                    .onAppear() {
                        if state.birdOfTheDayImage == nil {
                            state.getBirdOfTheDay()
                        }
                    }

                if let birdOfTheDay = state.birdOfTheDay,
                   let species = Species.species(for: birdOfTheDay.speciesID),
                   let image = state.birdOfTheDayImage
                {
                    BirdOfTheDay(isPresented: $state.showBirdOfTheDay.animation(), image: image, species: species)
                        .animation(.easeOut)
                        .transition(AnyTransition.move(edge: .bottom)
                                        .combined(with: AnyTransition.opacity.animation(.easeInOut(duration: 0.5))))
                        .zIndex(20)
                        .accessibility(sortPriority: 1000)
                }
            }
        }
        .alert(item: self.$state.alertItem, content: { (alertItem) -> Alert in
            alertItem.alert
        })
        .onAppear() {
            if SettingsStore.shared.startupCheckBirdOfTheDay {
                self.state.checkBirdOfTheDay()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged).receive(on: RunLoop.main), perform: { _ in
            if SettingsStore.shared.startupCheckBirdOfTheDay {
                self.state.checkBirdOfTheDay()
            }
        })
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
            .environmentObject(AppState.shared)
    }
}
