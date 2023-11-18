//
//  ContentView.swift
//  SwissBirds
//
//  Created by Philipp on 30.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Combine
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.horizontalSizeClass) private var sizeClass

    @ObservedObject var navigationState: NavigationState = AppState.shared.navigationState

    var body: some View {
        ZStack {
            NavigationView {
                if state.initialLoadRunning {
                    ProgressView()
                        .zIndex(1)
                } else {
                    if sizeClass == .regular {
                        BirdGrid()
                            .navigationBarTitle(Text("Vögel der Schweiz"))
                            .navigationBarItems(leading: sortButton, trailing: filterButton)
                            .background(dynamicNavigationLink)
                            .zIndex(2)

                    } else {
                        BirdList()
                            .navigationBarTitle(Text("Vögel der Schweiz"))
                            .navigationBarItems(leading: sortButton, trailing: filterButton)
                            .background(dynamicNavigationLink)
                            .zIndex(2)
                    }
                }
            }
            .navigationViewStyle(.stack)
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

                if state.birdOfTheDayImage == nil {
                    ProgressView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                                state.getBirdOfTheDay()
                            }
                        }
                } else if let birdOfTheDay = state.birdOfTheDay,
                        let species = Species.species(for: birdOfTheDay.speciesID),
                        let image = state.birdOfTheDayImage {
                    BirdOfTheDay(isPresented: $state.showBirdOfTheDay.animation(), image: image, species: species)
                        .animation(.easeOut, value: state.showBirdOfTheDay)
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
        .onAppear {
            if SettingsStore.shared.startupCheckBirdOfTheDay {
                state.checkBirdOfTheDay()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged).receive(on: DispatchQueue.main), perform: { _ in
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

    var dynamicNavigationLink: some View {
        NavigationLink(
            destination: presentNavigation(destination: navigationState.mainNavigation),
            isActive: Binding<Bool>(get: {
                navigationState.mainNavigation != nil
            }, set: { value in
                if !value {
                    navigationState.mainNavigation = nil
                }
            })
        ) {
            EmptyView()
        }
    }

    @ViewBuilder
    func presentNavigation(destination: NavigationState.MainNavigationLinkTarget?) -> some View {
        switch destination {
        case .filterList:
            FilterCriteria(managedList: state.filters)
        case .birdDetails(let species):
            BirdDetailContainer(model: state.currentBirdDetails, bird: species)
        case .sortOptions:
            SelectSortOptions(sorting: $state.sortOptions)
        default:
            EmptyView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState.shared)
            .environmentObject(FavoritesManager.shared)
    }
}
