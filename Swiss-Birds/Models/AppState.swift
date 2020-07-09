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
import Intents

class AppState : ObservableObject {

    @Published var searchText : String = ""
    @Published var isEditingSearchField: Bool = false

    var filters = ManagedFilterList()
    var restorableFilters: [String : [Filter.Id]] = [:]
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
                    self.updateSharedBirds()
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

                    // restore filter settings
                    self.filters.clearFilters()
                    self.restorableFilters.forEach { (key: String, value: [Filter.Id]) in
                        if let filterType = FilterType(rawValue: key) {
                            value.compactMap {
                                    Filter.filter(forId: $0, ofType: filterType)
                                }
                                .forEach {
                                    self.filters.toggleFilter($0)
                                }
                        }
                    }
                    self.restorableFilters.removeAll()
                })
            .store(in: &cancellables)

        // Combine the 3 data sources to restrict the bird list:
        Publishers.CombineLatest3($allSpecies, $searchText, filters.objectWillChange)
            .subscribe(on: DispatchQueue.global())
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.global())
            .map { [weak self] (input: ([Species], String, Void)) -> [Species] in
                guard let self = self else { return [] }
                let (allSpecies, searchText, _) = input
                let filtered = allSpecies
                    .filter({$0.categoryMatches(filters: self.filters.list) && $0.nameMatches(searchText)})
                return filtered
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.matchingSpecies, on: self)
            .store(in: &cancellables)
    }

    var initialLoadRunning: Bool {
        Filter.allFiltersGrouped.isEmpty || self.allSpecies.isEmpty
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
                    else {
                        self.donateBirdOfTheDayIntent()
                    }
                },
                receiveValue: { [unowned self] (image) in
                    self.birdOfTheDayImage = image
                })
            .store(in: &cancellables)
    }

    func showBird(_ speciesId: Int) {
        guard (selectedBirdId ?? -1) != speciesId,
              (restoredBirdId ?? -1) != speciesId
        else {
            print("bird \(speciesId) already shown")
            return
        }

        if showFilters || selectedBirdId != nil {
            if let currentBirdId = selectedBirdId {

                print("clear current selection: ", currentBirdId)
                selectedBirdId = nil
            }
            else if showFilters {
                print("closing filter")
                showFilters = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                print("Selecting bird: ", speciesId)
                self?.restoredBirdId = speciesId
            }
        }
        else {
            print("Selecting bird: ", speciesId)
            restoredBirdId = speciesId
        }
    }

    /// Returns the number of all species which would currently match the active filters
    func countFilterMatches() -> Int {
        return allSpecies.filter {$0.categoryMatches(filters: filters.list)}.count
    }

    func updateSharedBirds() {
        var dict = [String:Int]()
        self.allSpecies.forEach {
            dict[$0.name] = $0.speciesId
        }
        SettingsStore.shared.sharedBirds = dict

        INPreferences.requestSiriAuthorization { (status) in
            switch status {
                case .authorized:
                    os_log("updateSharedBirds: Siri is enabled")
                default:
                    break
            }
        }
    }

    func donateBirdOfTheDayIntent() {
        let intent = BirdOfTheDayIntent()
        intent.suggestedInvocationPhrase = "Show bird of the day"
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { (error) in
            if let error = error as NSError? {
                os_log("getBirdOfTheDay: Interaction donation failed: %@", log: OSLog.default, type: .error, error)
            } else {
                os_log("getBirdOfTheDay: Successfully donated interaction")
            }
        }
    }
}

extension AppState : CustomStringConvertible {
    var description: String {
        return "ApplicationState(searchText=\(searchText), showFilters=\(String(describing: showFilters)), activeFilters=\(filters), restorableFilters=\(String(describing: restorableFilters)), selectedBirdId=\(String(describing: selectedBirdId)), restoredBirdId=\(String(describing: restoredBirdId)), previousBirdOfTheDay=\(previousBirdOfTheDay)"
    }
}

// Save and restore state in UserActivity
extension AppState {

    func restore(from activity: NSUserActivity) {
        guard activity.activityType == Bundle.main.activityType,
            let stateArray : [String:Any] = activity.userInfo as? [String:Any]
            else { return }

        if let searchText = stateArray[Key.searchText] as? String {
            self.searchText = searchText
        }
        if let showFilters = stateArray[Key.showFilters] as? Bool {
            self.showFilters = showFilters
        }
        if let restoredFilters = stateArray[Key.activeFilters] as? [String : [Filter.Id]] {
            self.restorableFilters = restoredFilters
        }
        if let selectedBird = stateArray[Key.selectedBird] as? Species.Id, selectedBird > -1  {
            self.restoredBirdId = selectedBird
        }
        if let previousBirdOfTheDay = stateArray[Key.previousBirdOfTheDay] as? Int  {
            self.previousBirdOfTheDay = previousBirdOfTheDay
        }

        print("restored state: \(self)")
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
            Key.selectedBird: (selectedBirdId ?? restoredBirdId ?? -1) as Species.Id,
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
