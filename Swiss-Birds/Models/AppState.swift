//
//  AppState.swift
//  Swiss-Birds
//
//  Created by Philipp on 18.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI
import Combine

class AppState : ObservableObject {
    @Published var searchText : String = ""
    @Published var isEditingSearchField: Bool = false

    var filters = ManagedFilterList()
    @Published var allSpecies = [Species]()
    @Published var matchingSpecies = [Species]()
    @Published var error: Error?

    @Published var showFilters = false
    @Published var selectedBirdId : Species.Id?   // Bird currently selected in bird list view
    @Published var restoredBirdId : Species.Id?   // Bird selected in list view last time the app was stopped

    var cancellables = Set<AnyCancellable>()

    lazy var urlSession : URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: config)
    }()

    lazy var birdService : BirdService = {
        BirdService(urlSession: urlSession)
    }()

    var headShotsCache: [Species.Id:UIImage] = [:]

    // Singleton
    static var shared = AppState()

    private init() {
        // Fetch the birds data
        birdService
            .getBirds()
            .map { (birds: [VdsListElement]) -> [VdsListElement] in
                var dictionary = [String: VdsListElement]()
                birds.forEach { dictionary[$0.artID] = $0 }
                return Array(dictionary.values)
            }
            .map(loadSpeciesData)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.error = error
                    }
                }, receiveValue: { (species) in
                    self.allSpecies = species
            })
            .store(in: &cancellables)

        // Fetch filter data
        birdService
            .getFilters()
            .map(loadFilterData)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.error = error
                    }
                }, receiveValue: { (filters) in
                    Filter.allFiltersGrouped = filters
                    self.filters.objectWillChange.send()
            })
            .store(in: &cancellables)

        // Combine the 3 data sources to restrict the bird list:
        Publishers.CombineLatest3($allSpecies, $searchText, filters.objectWillChange)
            .subscribe(on: DispatchQueue.global())
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.global())
            .map { (input: ([Species], String, Void)) -> [Species] in
                let (allSpecies, searchText, _) = input
                let filtered = allSpecies
                    .filter({$0.categoryMatches(filters: self.filters.list) && $0.nameMatches(searchText)})
                print("filtered.count = \(filtered.count)")
                return filtered
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.matchingSpecies, on: self)
            .store(in: &cancellables)
    }

    func getHeadShot(for bird: Species) -> AnyPublisher<UIImage?, Never> {
        if let image = headShotsCache[bird.speciesId] {
            return Just(image).eraseToAnyPublisher()
        }
        return birdService
            .getSpecieHeadshot(for: bird.speciesId, scale: Int(UIScreen.main.scale))
            .map { self.headShotsCache[bird.speciesId] = $0; return $0 }
            .replaceError(with: UIImage(named: "placeholder-headshot"))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
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
