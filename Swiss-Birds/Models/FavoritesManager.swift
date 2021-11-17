//
//  FavoritesManager.swift
//  Swiss-Birds
//
//  Created by Philipp on 12.07.21.
//  Copyright © 2021 Philipp. All rights reserved.
//

import Foundation
import Combine

class FavoritesManager: ObservableObject {

    static var shared: FavoritesManager = {
        let settingsStore = SettingsStore.shared
        return FavoritesManager(settingsStore: settingsStore, userDefaults: .standard, favoriteSpecies: settingsStore.favoriteSpecies)
    }()

    private var cancellables = Set<AnyCancellable>()

    let userDefaults: UserDefaults
    let settingsStore: SettingsStore

    init(settingsStore: SettingsStore = .shared, userDefaults: UserDefaults = .standard, favoriteSpecies: [Int]? = nil) {
        self.settingsStore = settingsStore
        self.userDefaults = userDefaults
        self.favorites = Set(favoriteSpecies ?? settingsStore.favoriteSpecies)

        // Register as UserDefaults observer to update the favorites synched from iCloud
        userDefaults
            .publisher(for: \.sync_favoriteSpecies)
            .removeDuplicates()
            .map({ Set($0) })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newValue in
                guard let self = self,
                      self.changingFavorites == false,
                      self.favorites != newValue
                else {
                    return
                }
                self.favorites = newValue
            })
            .store(in: &cancellables)
    }

    @Published private(set) var favorites: Set<Species.Id>
    private var changingFavorites = false

    func toggleFavorite(_ species: Species) {
        changingFavorites = true

        if favorites.contains(species.speciesId) {
            favorites.remove(species.speciesId)
        } else {
            favorites.insert(species.speciesId)
        }

        settingsStore.favoriteSpecies = favorites.sorted()
        changingFavorites = false
    }

    func isFavorite(species: Species) -> Bool {
        favorites.contains(species.speciesId)
    }
}
