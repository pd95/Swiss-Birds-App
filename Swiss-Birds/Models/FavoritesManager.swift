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
    
    private init() { }
    
    @Published private(set) var favorites: Set<Species.Id> = Set(SettingsStore.shared.favoriteSpecies)

    func toggleFavorite(_ species: Species) {
        objectWillChange.send()

        if favorites.contains(species.speciesId) {
            favorites.remove(species.speciesId)
        }
        else {
            favorites.insert(species.speciesId)
        }
        
        SettingsStore.shared.favoriteSpecies = favorites.sorted()
    }
    
    func isFavorite(species: Species) -> Bool {
        favorites.contains(species.speciesId)
    }
}
