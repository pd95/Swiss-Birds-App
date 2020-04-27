//
//  AppState.swift
//  Swiss-Birds
//
//  Created by Philipp on 18.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI
import Combine

let appState = AppState()

class AppState : ObservableObject {
    @Published var searchText : String = ""
    @Published var isEditingSearchField: Bool = false

    var filters = ManagedFilterList()
    @Published var allSpecies = [Species]()
    @Published var matchingSpecies = [Species]()

    @Published var showFilters = false
    @Published var selectedBirdId : Species.Id?   // Bird currently selected in bird list view
    @Published var restoredBirdId : Species.Id?   // Bird selected in list view last time the app was stopped

    var cancellables = Set<AnyCancellable>()

    init() {
        Publishers.CombineLatest3($allSpecies, filters.objectWillChange, $searchText)
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.global())
            .map { (input: ([Species], (), String)) -> [Species] in
                let (allSpecies, _, searchText) = input
                let filtered = allSpecies
                    .filter({$0.categoryMatches(filters: self.filters.list) && $0.nameMatches(searchText)})
                print("filtered.count = \(filtered.count)")
                return filtered
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.matchingSpecies, on: self)
            .store(in: &cancellables)

        // Fetch the data and trigger a filter update
        allSpecies = loadSpeciesData()
        filters.objectWillChange.send()
    }

    /// Returns the number of all species which would currently match the active filters
    func countFilterMatches() -> Int {
        return allSpecies.filter {$0.categoryMatches(filters: filters.list)}.count
    }
}

extension AppState : CustomStringConvertible {
    var description: String {
        return "ApplicationState(searchText=\(searchText), showFilters=\(String(describing:showFilters)), activeFilters=\(filters), selectedBirdId=\(String(describing:selectedBirdId)))"
    }
}

// Save and restore state in UserActivity
extension AppState {

    func restore(from activity: NSUserActivity) {
        guard activity.activityType == Bundle.main.activityType,
            let stateArray : [String:Any] = activity.userInfo as? [String:Any]
            else { return }
       
        // Apply state changes asynchronously
        DispatchQueue.main.async {
            
            if let searchText = stateArray[Key.searchText] as? String {
                self.searchText = searchText
            }
            if let showFilters = stateArray[Key.showFilters] as? Bool {
                self.showFilters = showFilters
            }
            if let restoredList = stateArray[Key.activeFilters] as? [String : [Filter.Id]] {
                self.filters.clearFilters()
                restoredList.forEach { (key: String, value: [Filter.Id]) in
                    if let filterType = FilterType(rawValue: key) {
                        value.compactMap { Filter.filter(forId: $0, ofType: filterType) }
                            .forEach { self.filters.toggleFilter($0) }
                    }
                }
            }
            if let selectedBird = stateArray[Key.selectedBird] as? Species.Id, selectedBird > -1  {
                self.restoredBirdId = selectedBird
            }
            
            print("restored state: \(self)")
        }
    }
    
    func store(in activity: NSUserActivity) {
        var storableList = [String : [Filter.Id]]()
        self.filters.list.forEach { (key: FilterType, value: [Filter.Id]) in
            storableList[key.rawValue] = value
        }

        let stateArray : [String:Any] = [
            Key.searchText: searchText,
            Key.showFilters: showFilters,
            Key.activeFilters: storableList,
            Key.selectedBird: (selectedBirdId ?? -1) as Species.Id,
        ]
        activity.addUserInfoEntries(from: stateArray)
        
        print("saved state: \(self)")
    }
    
    private enum Key {
        static let searchText = "searchText"
        static let showFilters = "showFilters"
        static let activeFilters = "activeFilters"
        static let selectedBird = "selectedBird"
    }
}
