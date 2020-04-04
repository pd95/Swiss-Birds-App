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
    @Published var selectedFilters = [FilterType:[Int]]()
    @Published var showFilters = false
    @Published var selectedBirdId : Int?    // Bird currently selected in bird list view
    @Published var restoredBirdId : Int?   // Bird selected in list view last time the app was stopped
}

extension AppState : CustomStringConvertible {
    var description: String {
        return "ApplicationState(searchText=\(searchText), showFilters=\(String(describing:showFilters)), selectedFilters=\(selectedFilters), selectedBirdId=\(String(describing:selectedBirdId)))"
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
            if let selectedFilters = stateArray[Key.selectedFilters] as? [String : [Int]] {
                self.selectedFilters.removeAll()
                selectedFilters.forEach { (key: String, value: [Int]) in
                    if let filter = FilterType(rawValue: key) {
                        self.selectedFilters[filter] = value
                    }
                }
            }
            if let selectedBird = stateArray[Key.selectedBird] as? Int, selectedBird > -1  {
                self.restoredBirdId = selectedBird
            }
            
            print("restored state: \(self)")
        }
    }
    
    func store(in activity: NSUserActivity) {
        var selectedFilters = [String : [Int]]()
        self.selectedFilters.forEach { (key: FilterType, value: [Int]) in
            selectedFilters[key.rawValue] = value
        }

        let stateArray : [String:Any] = [
            Key.searchText: searchText,
            Key.showFilters: showFilters,
            Key.selectedFilters: selectedFilters,
            Key.selectedBird: (selectedBirdId ?? -1) as Int,
        ]
        activity.addUserInfoEntries(from: stateArray)
        
        print("saved state: \(self)")
    }
    
    private enum Key {
        static let searchText = "searchText"
        static let showFilters = "showFilters"
        static let selectedFilters = "selectedFilters"
        static let selectedBird = "selectedBird"
    }
}


extension Bundle {
    var activityType: String {
        return Bundle.main.infoDictionary?["NSUserActivityTypes"].flatMap { ($0 as? [String])?.first } ?? ""
    }
}
