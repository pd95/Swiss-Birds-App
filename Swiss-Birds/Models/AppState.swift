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

// Enumeration of all possible cases of the current selected NavigationLink
enum MainNavigationLinkTarget: Hashable, Codable {
    case filterList
    case birdDetails(Int)
    case programmaticBirdDetails(Int)


    // MARK: Codable protocol
    enum Key: CodingKey {
        case rawValue
        case associatedValue
    }

    enum CodingError: Error {
        case unknownValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
        case 0:
            self = .filterList
        case 1:
            let speciesId = try container.decode(Int.self, forKey: .associatedValue)
            self = .birdDetails(speciesId)
        case 2:
            let speciesId = try container.decode(Int.self, forKey: .associatedValue)
            self = .programmaticBirdDetails(speciesId)
        default:
            throw CodingError.unknownValue
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .filterList:
            try container.encode(0, forKey: .rawValue)
        case .birdDetails(let speciesId):
            try container.encode(1, forKey: .rawValue)
            try container.encode(speciesId, forKey: .associatedValue)
        case .programmaticBirdDetails(let speciesId):
            try container.encode(2, forKey: .rawValue)
            try container.encode(speciesId, forKey: .associatedValue)
        }
    }
}

class AppState : ObservableObject {

    @Published var searchText : String = ""
    @Published var isEditingSearchField: Bool = false

    var filters = ManagedFilterList()
    var restorableFilters: [String : [Filter.Id]] = [:]
    @Published var allSpecies = [Species]()
    @Published var matchingSpecies = [Species]()
    @Published var error: Error?

    @Published var selectedNavigationLink: MainNavigationLinkTarget? = nil

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

    func checkBirdOfTheDay(showAlways: Bool = false) {
        os_log("checkBirdOfTheDay(showAlways: %d)", showAlways)
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
                        self.showBirdOfTheDay = showAlways || (currentBirdOfTheDay > -1 && self.previousBirdOfTheDay != currentBirdOfTheDay)
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

    func showBird(_ speciesId: Int) {
        if isEditingSearchField {
            UIApplication.shared.endEditing()
        }

        selectedNavigationLink = .programmaticBirdDetails(speciesId)
    }

    func showFilter() {
        if isEditingSearchField {
            UIApplication.shared.endEditing()
        }

        selectedNavigationLink = .filterList
    }

    /// Returns the number of all species which would currently match the active filters
    func countFilterMatches() -> Int {
        return allSpecies.filter {$0.categoryMatches(filters: filters.list)}.count
    }
}

extension AppState : CustomStringConvertible {
    var description: String {
        return "ApplicationState(searchText=\(searchText), selectedNavigationLink=\(String(describing: selectedNavigationLink)), activeFilters=\(filters), restorableFilters=\(String(describing: restorableFilters)), previousBirdOfTheDay=\(previousBirdOfTheDay)"
    }
}

// Save and restore state in UserActivity
extension AppState {

    func restore(from activity: NSUserActivity) {
        os_log("restore(from: %{public}@%)", activity.activityType)
        guard activity.activityType == Bundle.main.activityType,
            let stateArray : [String:Any] = activity.userInfo as? [String:Any]
            else { return }

        if let searchText = stateArray[Key.searchText] as? String {
            self.searchText = searchText
        }
        if let restoredFilters = stateArray[Key.activeFilters] as? [String : [Filter.Id]] {
            self.restorableFilters = restoredFilters
        }
        if let previousBirdOfTheDay = stateArray[Key.previousBirdOfTheDay] as? Int  {
            self.previousBirdOfTheDay = previousBirdOfTheDay
        }

        // Restore latest navigation
        if let selectedNavigationLinkData = stateArray[Key.selectedNavigationLink] as? Data {
            self.selectedNavigationLink = try? JSONDecoder().decode(MainNavigationLinkTarget.self, from: selectedNavigationLinkData)
        }

        os_log("restore(from: %{public}@): %{public}@", activity.activityType, self.description)
    }
    
    func store(in activity: NSUserActivity) {
        os_log("store(in: %{public}@)", activity.activityType)
        var storableList = [String : [Filter.Id]]()
        self.filters.list.forEach { (key: FilterType, value: [Filter.Id]) in
            storableList[key.rawValue] = value
        }
        let selectedNavigationLinkData = (try? JSONEncoder().encode(selectedNavigationLink)) ?? Data()

        let stateArray : [String:Any] = [
            Key.searchText: searchText,
            Key.activeFilters: storableList,
            Key.selectedNavigationLink: selectedNavigationLinkData,
            Key.previousBirdOfTheDay: previousBirdOfTheDay as Species.Id,
        ]
        activity.addUserInfoEntries(from: stateArray)

        os_log("store(in: %{public}@): %{public}@", activity.activityType, self.description)
    }
    
    private enum Key {
        static let searchText = "searchText"
        static let activeFilters = "activeFilters"
        static let previousBirdOfTheDay = "previousBirdOfTheDay"
        static let selectedNavigationLink = "selectedNavigationLink"
    }
}
