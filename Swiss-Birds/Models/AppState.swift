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
import WidgetKit

// Enumeration of all possible cases of the current selected NavigationLink
enum MainNavigationLinkTarget: Hashable, Codable {
    case filterList
    case birdDetails(Int)
    case programmaticBirdDetails(Int)
    case sortOptions


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
        case 3:
            self = .sortOptions
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
        case .sortOptions:
            try container.encode(3, forKey: .rawValue)
        }
    }
}

class AppState : ObservableObject {

    @Published var searchText : String = ""
    @Published var isEditingSearchField: Bool = false

    var filters = ManagedFilterList()
    @Published var sortOptions = SortOptions(column: .speciesName)
    var restorableFilters: [String : [Filter.Id]] = [:]
    @Published var allSpecies = [Species]()
    @Published var groupedBirds = [String: [Species]]()
    @Published var groups = [String]()
    var listID = UUID()

    @Published var alertItem: AlertItem?
    var error: Error? {
        willSet {
            objectWillChange.send()
        }
        didSet {
            if let error = error {
                alertItem = AlertItem(title: Text("An error occurred"),
                      message: Text(error.localizedDescription),
                      dismissButton: .default(Text("Dismiss")))
            }
        }
    }


    @Published var selectedNavigationLink: MainNavigationLinkTarget? = nil

    var selectedNavigationLinkBinding: Binding<MainNavigationLinkTarget?> {
        // Define custom bindings to avoid "duplicate assignments" (which often causes navigation hick-ups)
        Binding<MainNavigationLinkTarget?>(
            get: { self.selectedNavigationLink },
            set: { (newValue) in
                // Workaround flickering and non-visible list selection on iPad by ignoring `nil` assignment
                if UIDevice.current.userInterfaceIdiom == .pad && newValue == nil {
                    return
                }
                if self.selectedNavigationLink != newValue {
                    self.selectedNavigationLink = newValue
                }
            })
    }

    var previousBirdOfTheDay: Int = -1
    var birdOfTheDayCheckDate: Date?
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
                    self.filters.removeAll()
                    self.restorableFilters.forEach { (key: String, value: [Filter.Id]) in
                        if let filterType = FilterType(rawValue: key) {
                            value.compactMap {
                                    Filter.filter(forId: $0, ofType: filterType)
                                }
                                .forEach {
                                    self.filters.toggle(filter: $0)
                                }
                        }
                    }
                    self.restorableFilters.removeAll()
                })
            .store(in: &cancellables)

        // Combine the 3 data sources to restrict the bird list:
        let backgroundQueue = DispatchQueue(label: "Bird-List-Prepare")
        let cleanSearchTextPublisher = $searchText
            .debounce(for: .seconds(0.5), scheduler: backgroundQueue)
            .removeDuplicates()

        let cleanSortOptions = $sortOptions
            .debounce(for: .seconds(0.3), scheduler: backgroundQueue)
            .removeDuplicates()
            .handleEvents(receiveOutput: { [weak self] sortOptions in
                os_log("sortOptions changed receiveValue %{Public}@", sortOptions.description)
                let newID = UUID()
                self?.listID = newID
                os_log("Resetting list %{Public}@", newID.description)
            })

        Publishers.CombineLatest4($allSpecies, cleanSearchTextPublisher, filters.objectWillChange, cleanSortOptions)
            .handleEvents(receiveOutput: { _ in os_log("groupedBirds input changed") })
            .receive(on: backgroundQueue)
            .debounce(for: .seconds(0.1), scheduler: backgroundQueue)
            .map { [weak self] (allSpecies: [Species], searchText: String, unused: Void, sortOptions: SortOptions) -> ([String:[Species]], [String]) in
                guard let self = self else { return ([:], []) }

                os_log("start filtering bird list: %ld", allSpecies.count)

                // Filter species
                let filtered = allSpecies
                    .filter({$0.categoryMatches(filters: self.filters.list) && $0.nameMatches(searchText)})
                os_log("filtering bird list done: %ld", filtered.count)

                let groupedBirds: [String:[Species]]
                let sortedGroups: [String]
                let groupOption = sortOptions.column
                os_log("group according to %{Public}@", groupOption.rawValue)
                if case .filterType(let type) = groupOption {
                    let groupedBirdsByFilter = Dictionary(
                        grouping: filtered,
                        by: { (species: Species) -> Filter in
                            species.filterValue(type) ?? Filter.undefined
                        }
                    )
                    let filterGroups = groupedBirdsByFilter.keys
                    sortedGroups = filterGroups.sorted().map(\.name)
                    let uniqueKeysWithValues = groupedBirdsByFilter.map { entry -> (key: String, value: [Species]) in
                        let (filter, value) = entry
                        return (key: filter.name, value: value)
                    }
                    groupedBirds = Dictionary(uniqueKeysWithValues: uniqueKeysWithValues)
                }
                else {
                    groupedBirds = Dictionary(
                        grouping: filtered,
                        by: { (species: Species) -> String in
                            String(species.name.first ?? "#")
                        }
                    )
                    sortedGroups = groupedBirds.keys.sorted()
                }
                os_log("grouping done: %ld groups", groupedBirds.keys.count)

                return (groupedBirds, sortedGroups)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (groupedBirds, groups) in
                os_log("Storing bird list and triggering redraw")
                self?.groupedBirds = groupedBirds
                self?.groups = groups
            })
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

        // No need to refetch the data if we already checked today...
        if let lastCheckDate = birdOfTheDayCheckDate,
           Calendar.current.startOfDay(for: Date()) <= lastCheckDate {
            os_log("  already checked on %{Public}@", lastCheckDate.description)
            if showAlways {
                self.showBirdOfTheDayNow()
            }
            return
        }

        // Fetch the bird of the day
        VdsAPI
            .getBirdOfTheDaySpeciesIDandURL()
            .map {Optional.some($0)}
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] result in
                    if case .failure(let error) = result {
                        self?.error = error
                        os_log("getBirdOfTheDaySpeciesIDandURL error: %{Public}@", error.localizedDescription)
                        self?.birdOfTheDay = nil
                    }
                },
                receiveValue: { [weak self] (birdOfTheDay) in
                    self?.birdOfTheDay = birdOfTheDay
                    self?.birdOfTheDayCheckDate = Date()
                    if let botd = birdOfTheDay {
                        let currentBirdOfTheDay = botd.speciesID
                        let isNewBirdOfTheDay = (currentBirdOfTheDay > -1 && self?.previousBirdOfTheDay != currentBirdOfTheDay)
                        if showAlways || isNewBirdOfTheDay {
                            self?.showBirdOfTheDayNow()
                        }
                        if isNewBirdOfTheDay {
                            self?.refreshWidget()
                        }
                    }
                })
            .store(in: &cancellables)
    }

    private func refreshWidget() {
        if #available(iOS 14.0, *) {
            os_log("refreshWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "BirdOfTheDayWidget")
        }
    }

    func getBirdOfTheDay() {
        guard let speciesId = birdOfTheDay?.speciesID else {
            return
        }
        VdsAPI
            .getBirdOfTheDay(for: speciesId)
            .map { [weak self] data in
                let image = UIImage(data: data)
                self?.headShotsCache[-speciesId] = image
                return image
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] (result) in
                    if case .failure(let error) = result {
                        self?.error = error
                        os_log("getBirdOfTheDay error: %{Public}@", error.localizedDescription)
                        self?.birdOfTheDayImage = nil
                    }
                },
                receiveValue: { [weak self] (image) in
                    self?.birdOfTheDayImage = image
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

    func showSortOptions() {
        if isEditingSearchField {
            UIApplication.shared.endEditing()
        }

        selectedNavigationLink = .sortOptions
    }

    func showBirdOfTheDayNow() {
        if isEditingSearchField {
            UIApplication.shared.endEditing()
        }

        withAnimation {
            selectedNavigationLink = nil
            showBirdOfTheDay = true
        }
    }

    /// Returns the number of all species which would currently match the active filters
    func countFilterMatches() -> Int {
        return allSpecies.filter {$0.categoryMatches(filters: filters.list)}.count
    }
}

extension AppState : CustomStringConvertible {
    var description: String {
        return "ApplicationState(searchText=\(searchText), selectedNavigationLink=\(String(describing: selectedNavigationLink)), activeFilters=\(filters), restorableFilters=\(String(describing: restorableFilters)), previousBirdOfTheDay=\(previousBirdOfTheDay), showBirdOfTheDay=\(showBirdOfTheDay), sortOptions=\(sortOptions))"
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
        if let selectedNavigationLinkData = stateArray[Key.selectedNavigationLink] as? Data,
            let selectedNavigationLink = try? JSONDecoder().decode(MainNavigationLinkTarget.self, from: selectedNavigationLinkData) {
            if case .birdDetails(let speciesId) = selectedNavigationLink {
                self.selectedNavigationLink = .programmaticBirdDetails(speciesId)
            }
            else {
                self.selectedNavigationLink = selectedNavigationLink
            }
        }

        if let sortByColumn = stateArray[Key.sortByColumn] as? SortOptions.SortColumn.RawValue,
           let columnOption = SortOptions.SortColumn(rawValue: sortByColumn)
        {
            self.sortOptions.column = columnOption
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
            Key.sortByColumn: sortOptions.column.rawValue,
        ]
        activity.addUserInfoEntries(from: stateArray)

        os_log("store(in: %{public}@): %{public}@", activity.activityType, self.description)
    }
    
    private enum Key {
        static let searchText = "searchText"
        static let activeFilters = "activeFilters"
        static let previousBirdOfTheDay = "previousBirdOfTheDay"
        static let selectedNavigationLink = "selectedNavigationLink"
        static let sortByColumn = "sortByColumn"
    }
}
