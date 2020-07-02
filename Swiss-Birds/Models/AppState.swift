//
//  AppState.swift
//  Swiss-Birds
//
//  Created by Philipp on 18.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import os.log
import SwiftUI
import Combine

class AppState : ObservableObject {
    @Published var initialLoadRunning: Bool

    @Published var searchText : String = ""
    @Published var isEditingSearchField: Bool = false

    var filters = ManagedFilterList()
    @Published var allSpecies = [Species]()
    @Published var matchingSpecies = [Species]()
    @Published var error: Error?

    @Published var showFilters = false
    @Published var selectedBirdId : Species.Id?   // Bird currently selected in bird list view
    @Published var restoredBirdId : Species.Id?   // Bird selected in list view last time the app was stopped

    var previousBirdOfTheDay: Int = -1
    @Published var birdOfTheDay: VdsAPI.BirdOfTheDayData?
    @Published var birdOfTheDayImage: UIImage?
    @Published var showBirdOfTheDay: Bool = false

    var cancellables = Set<AnyCancellable>()

    var headShotsCache: [Species.Id:UIImage] = [:]

    // Singleton
    static var shared = AppState()

    private init() {
        initialLoadRunning = true

        // Fetch the birds data
        VdsAPI
            .getBirds()
            .map { (birds: [VdsListElement]) -> [VdsListElement] in
                var dictionary = [String: VdsListElement]()
                birds.forEach { dictionary[$0.artID] = $0 }
                return Array(dictionary.values)
            }
            .map(loadSpeciesData)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    if case .failure(let error) = completion {
                        self.error = error
                        os_log("getBirds error: %{Public}@", error.localizedDescription)
                    }
                    self.initialLoadRunning = false
                },
                receiveValue: { [weak self] species in
                    guard let self = self else { return }
                    self.allSpecies = species
                })
            .store(in: &cancellables)

        // Fetch filter data
        VdsAPI
            .getFilters()
            .map(loadFilterData)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    if case .failure(let error) = completion {
                        self.error = error
                        os_log("getFilters error: %{Public}@", error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] filters in
                    guard let self = self else { return }
                    Filter.allFiltersGrouped = filters
                    self.filters.objectWillChange.send()
                })
            .store(in: &cancellables)

        // Combine the 3 data sources to restrict the bird list:
        Publishers.CombineLatest3($allSpecies, $searchText, filters.objectWillChange)
            .subscribe(on: DispatchQueue.global())
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .map { [weak self] (input: ([Species], String, Void)) -> [Species] in
                guard let self = self else { return [] }
                let (allSpecies, searchText, _) = input
                let filtered = allSpecies
                    .filter({$0.categoryMatches(filters: self.filters.list) && $0.nameMatches(searchText)})
                return filtered
            }
            .assign(to: \.matchingSpecies, on: self)
            .store(in: &cancellables)
    }

    func getHeadShot(for bird: Species) -> AnyPublisher<UIImage?, Never> {
        if let image = headShotsCache[bird.speciesId] {
            return Just(image).eraseToAnyPublisher()
        }
        return VdsAPI
            .getSpecieHeadshot(for: bird.speciesId, scale: Int(UIScreen.main.scale))
            .receive(on: DispatchQueue.main)
            .map { [weak self] data in
                let image = UIImage(data: data)
                self?.headShotsCache[bird.speciesId] = image
                return image
            }
            .replaceError(with: UIImage(named: "placeholder-headshot"))
            .eraseToAnyPublisher()
    }

    func checkBirdOfTheDay() {
        if !SettingsStore.shared.startupCheckBirdOfTheDay {
            return
        }
        // Fetch the bird of the day
        VdsAPI
            .getBirdOfTheDaySpeciesIDandURL()
            .map {Optional.some($0)}
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [unowned self] result in
                    if case .failure(let error) = result {
                        self.error = error
                        os_log("getBirdOfTheDaySpeciesIDandURL error: %{Public}@", error.localizedDescription)
                        self.birdOfTheDay = nil
                    }
                },
                receiveValue: { [unowned self] (birdOfTheDay) in
                    self.birdOfTheDay = birdOfTheDay
                    if let botd = birdOfTheDay {
                        let currentBirdOfTheDay = botd.speciesID
                        self.showBirdOfTheDay = currentBirdOfTheDay > -1 && self.previousBirdOfTheDay != currentBirdOfTheDay
                    }
                })
            .store(in: &cancellables)
    }

    func getBirdOfTheDay() {
        guard let speciesId = birdOfTheDay?.speciesID else {
            return
        }
        VdsAPI
            .getBirdOfTheDay(for: speciesId)
            .map { [unowned self] data in
                let image = UIImage(data: data)
                self.headShotsCache[-speciesId] = image
                return image
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [unowned self] (result) in
                    if case .failure(let error) = result {
                        self.error = error
                        os_log("getBirdOfTheDay error: %{Public}@", error.localizedDescription)
                        self.birdOfTheDayImage = nil
                    }
                },
                receiveValue: { [unowned self] (image) in
                    self.birdOfTheDayImage = image
                })
            .store(in: &cancellables)
    }

    /// Returns the number of all species which would currently match the active filters
    func countFilterMatches() -> Int {
        return allSpecies.filter {$0.categoryMatches(filters: filters.list)}.count
    }
}

extension AppState : CustomStringConvertible {
    var description: String {
        return "ApplicationState(searchText=\(searchText), showFilters=\(String(describing:showFilters)), activeFilters=\(filters), selectedBirdId=\(String(describing:selectedBirdId)), previousBirdOfTheDay=\(previousBirdOfTheDay)"
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
            if let previousBirdOfTheDay = stateArray[Key.previousBirdOfTheDay] as? Int  {
                self.previousBirdOfTheDay = previousBirdOfTheDay
                //self.previousBirdOfTheDay = -1
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
            Key.previousBirdOfTheDay: previousBirdOfTheDay as Species.Id,
        ]
        activity.addUserInfoEntries(from: stateArray)
        
        print("saved state: \(self)")
    }
    
    private enum Key {
        static let searchText = "searchText"
        static let showFilters = "showFilters"
        static let activeFilters = "activeFilters"
        static let selectedBird = "selectedBird"
        static let previousBirdOfTheDay = "previousBirdOfTheDay"
    }
}
