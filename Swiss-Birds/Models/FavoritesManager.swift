//
//  FavoritesManager.swift
//  Swiss-Birds
//
//  Created by Philipp on 12.07.21.
//  Copyright © 2021 Philipp. All rights reserved.
//

import Foundation
import Combine

class FavoritesManager: NSObject, ObservableObject {
    
    static let shared = FavoritesManager()
    
    private override init() {
        super.init()
        // Register ourself as UserDefaults observer to update the favorites synched from iCloud
        UserDefaults.standard.addObserver(
            self,
            forKeyPath: UserDefaults.Keys.favoriteSpecies,
            options: [.old,.new],
            context: nil
        )
    }
    
    deinit {
        // Be a good citizen and clean-up behind yourself
        UserDefaults.standard.removeObserver(self, forKeyPath: UserDefaults.Keys.favoriteSpecies)
    }
    
    @Published private(set) var favorites: Set<Species.Id> = Set(SettingsStore.shared.favoriteSpecies)
    private var changingFavorites = false

    func toggleFavorite(_ species: Species) {
        changingFavorites = true
        objectWillChange.send()

        if favorites.contains(species.speciesId) {
            favorites.remove(species.speciesId)
        }
        else {
            favorites.insert(species.speciesId)
        }
        
        SettingsStore.shared.favoriteSpecies = favorites.sorted()
        changingFavorites = false
    }
    
    func isFavorite(species: Species) -> Bool {
        favorites.contains(species.speciesId)
    }

    /// KVO function triggered whenever a change is observed.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard changingFavorites == false else {
            return
        }
        if let newValue = change?[.newKey] as? [Int] {
            favorites = Set(newValue)
        }
    }
}
