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
                        .navigationBarTitle(Text("Vögel der Schweiz"))
                        .navigationBarItems(leading: sortButton, trailing: filterButton)
                        .zIndex(2)

                    OnboardingView()
                }
            }
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
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
        .alert(item: $state.alertItem, content: { (alertItem) -> Alert in
            alertItem.alert
        })
        .onAppear() {
            if SettingsStore.shared.startupCheckBirdOfTheDay {
                state.checkBirdOfTheDay()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged).receive(on: RunLoop.main), perform: { _ in
            if SettingsStore.shared.startupCheckBirdOfTheDay {
                state.checkBirdOfTheDay()
            }
        })
    }

    var sortButton: some View {
        Button(action: state.showSortOptions) {
            HStack {
                Image(systemName: "arrow.up.arrow.down.circle")
                    .imageScale(.large)
            }
            .padding(4)
        }
        .hoverEffect()
        .accessibility(identifier: "sortButton")
    }

    var filterButton: some View {
        Button(action: state.showFilter) {
            Text("Filter")
                .padding(4)
                .overlay(Group {
                    if !state.filters.isEmpty {
                        Image(systemName: "\(state.filters.count).circle.fill")
                            .imageScale(.small)
                            .offset(x: 9, y: -3)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .foregroundColor(.secondary)
                    }
                })
                .accessibilityElement(children: .combine)
        }
        .hoverEffect()
        .disabled(Filter.allFiltersGrouped.isEmpty)
        .accessibility(identifier: "filterButton")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState.shared)
    }
}
