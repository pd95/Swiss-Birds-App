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

    @State private var showBirdOfTheDay = false
    @State private var showButton = false

    var body: some View {
        ZStack {
            if self.state.birdOfTheDay == nil {
                ActivityIndicatorView()
            }
            else {
                if showButton {
                    Button("Show again") {
                        self.showBirdOfTheDay = true
                    }
                }
                if showBirdOfTheDay {
                    BirdOfTheDay(isPresented: $showBirdOfTheDay.animation(), url: self.state.birdOfTheDay!.url, speciesId: self.state.birdOfTheDay!.speciesID)
                        .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity))
                        .onDisappear() {
                            self.showButton = true
                        }
                }
            }
        }
        .onAppear() {
            self.state.checkBirdOfTheDay()
        }
        .onReceive(state.$showBirdOfTheDay.debounce(for: .seconds(1), scheduler: RunLoop.main)) { value in
            withAnimation {
                self.showBirdOfTheDay = value
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}
