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

    static let shared = FavoritesManager()

    private var cancellables = Set<AnyCancellable>()

    private init() {
        // Register as UserDefaults observer to update the favorites synched from iCloud
        UserDefaults.standard
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

    @Published private(set) var favorites: Set<Species.Id> = Set(SettingsStore.shared.favoriteSpecies)
    private var changingFavorites = false

    func toggleFavorite(_ species: Species) {
        changingFavorites = true
        objectWillChange.send()

        if favorites.contains(species.speciesId) {
            favorites.remove(species.speciesId)
        } else {
            favorites.insert(species.speciesId)
        }

        SettingsStore.shared.favoriteSpecies = favorites.sorted()
        changingFavorites = false
    }

    func isFavorite(species: Species) -> Bool {
        favorites.contains(species.speciesId)
    }
}
