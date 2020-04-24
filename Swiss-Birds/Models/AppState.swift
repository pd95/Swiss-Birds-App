//
//  AppState.swift
//  Swiss-Birds
//
//  Created by Philipp on 18.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI

let appState = AppState()

class AppState : ObservableObject {
    @Published var searchText : String = ""

    var filterManager = FilterManager.shared

    @Published var showFilters = false
    @Published var selectedBirdId : Species.Id?    // Bird currently selected in bird list view
    @Published var restoredBirdId : Species.Id?   // Bird selected in list view last time the app was stopped
}

extension AppState : CustomStringConvertible {
    var description: String {
        return "ApplicationState(searchText=\(searchText), showFilters=\(String(describing:showFilters)), activeFilters=\(filterManager.activeFilters), selectedBirdId=\(String(describing:selectedBirdId)))"
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
            if let activeFilters = stateArray[Key.activeFilters] as? [String : [Filter.Id]] {
                self.filterManager.clearFilters()
                activeFilters.forEach { (key: String, value: [Filter.Id]) in
                    if let filterType = FilterType(rawValue: key) {
                        for id in value {
                            if let filter = Filter.filter(forId: id, ofType: filterType) {
                                self.filterManager.toggleFilter(filter)
                            }
                        }
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
        var activeFilters = [String : [Filter.Id]]()
        self.filterManager.activeFilters.forEach { (key: FilterType, value: [Filter.Id]) in
            activeFilters[key.rawValue] = value
        }

        let stateArray : [String:Any] = [
            Key.searchText: searchText,
            Key.showFilters: showFilters,
            Key.activeFilters: activeFilters,
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
