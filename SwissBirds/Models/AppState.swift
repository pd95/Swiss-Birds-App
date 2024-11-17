//
//  AppState.swift
//  SwissBirds
//
//  Created by Philipp on 18.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import os.log
import SwiftUI
import Combine
import WidgetKit

class AppState: ObservableObject {

    @Published var searchText: String = ""
    @Published var isEditingSearchField: Bool = false

    var filters = ManagedFilterList()

    @Published var sortOptions = SortOptions(column: .speciesName) {
        didSet {
            // Sync value with UserDefaults
            settingsStore.groupColumn = sortOptions.column.rawValue
        }
    }

    var restorableFilters: [String: [Filter.Id]] = [:]
    @Published var allSpecies = [Species]()
    var groupedBirds = [SectionGroup: [Species]]()
    var groups = [SectionGroup]()
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

    var navigationState = NavigationState()

    // Single view model used in BirdDetailView, updated when selected bird changes
    @MainActor
    let currentBirdDetails = BirdDetailViewModel()

    var previousBirdOfTheDay: Int = -1
    var birdOfTheDayCheckDate: Date?
    @Published var birdOfTheDay: VdsAPI.BirdOfTheDayData?
    @Published var birdOfTheDayImage: UIImage?
    @Published var showBirdOfTheDay: Bool = false

    var cancellables = Set<AnyCancellable>()

    var headShotsCache: [Species.Id: UIImage] = [:]

    // Shared instance
    static var shared = AppState()

    let favoritesManager: FavoritesManager
    let settingsStore: SettingsStore
    let logger = Logger(subsystem: "AppState", category: "general")

    init(favoritesManager: FavoritesManager = .shared, settingsStore: SettingsStore = .shared ) {
        self.favoritesManager = favoritesManager
        self.settingsStore = settingsStore

        let logger = self.logger
        logger.debug(#function)

        // Init sort options with value stored in UserDefaults
        if let sortColumn = SortOptions.SortColumn(rawValue: settingsStore.groupColumn) {
            sortOptions = SortOptions(column: sortColumn)
        }

        // Fetch the birds data
        preferredLanguageOrder.publisher
            .setFailureType(to: Error.self)
            .flatMap({ language in
                // Fetch for each languages
                logger.debug("Fetch bird data for \(language)")
                return VdsAPI.getBirds(language: language)
                    .map { birds -> [String: VdsListElement] in
                        logger.debug("Received bird data in \(language)")
                        var dictionary = [String: VdsListElement]()
                        birds.forEach { dictionary[$0.artID] = $0 }
                        return dictionary
                    }
                    .map({(language: language, birds: $0)})
            })
            .collect()
            .map({ (allBirdData: [(language: LanguageIdentifier, birds: [String: VdsListElement])]) -> [Species] in
                logger.debug("Collected all bird data for \(allBirdData.map(\.language))")

                // Merge for easier mapping
                var indexedBirdData = [LanguageIdentifier: [String: VdsListElement]]()
                for birdData in allBirdData {
                    indexedBirdData[birdData.language] = birdData.birds
                }

                // Transform data from primary language
                let primarySpecies = loadSpeciesData(vdsList: Array(indexedBirdData[primaryLanguage]!.values))

                // And enrich with other languages name
                var allSpecies = [Species]()
                for species in primarySpecies {
                    for language in preferredLanguageOrder where language != primaryLanguage {
                        if let otherBirdData = indexedBirdData[language]![String(species.speciesId)] {
                            species.addTranslation(for: language, vdsListElement: otherBirdData)
                        }
                    }
                    allSpecies.append(species)
                }
                return allSpecies
            })
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    if case .failure(let error) = completion {
                        self.error = error
                        logger.error("getBirds error: \(error.localizedDescription, privacy: .public)")
                    }
                },
                receiveValue: { [weak self] species in
                    guard let self = self else { return }
                    logger.debug("getBirds storing \(species.count) species")
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
                        logger.error("getFilters error: \(error.localizedDescription, privacy: .public)")
                    }
                },
                receiveValue: { [weak self] filters in
                    guard let self = self else { return }
                    Filter.allFiltersGrouped = filters
                    logger.debug("getFilters storing \(filters.count) filters")
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
                    logger.debug("getFilters restored setting of \(restorableFilters.count) filters")
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
                logger.debug("sortOptions changed receiveValue \(sortOptions.description, privacy: .public)")
                let newID = UUID()
                self?.listID = newID
                logger.debug("Resetting list \(newID.description, privacy: .public)")
            })

        Publishers.CombineLatest($allSpecies, filters.objectWillChange)
            .combineLatest(cleanSearchTextPublisher, cleanSortOptions, favoritesManager.$favorites) {
                ($0.0, $1, $2, $3)
            }
            .handleEvents(receiveOutput: { _ in logger.debug("groupedBirds input changed") })
            .receive(on: backgroundQueue)
            .debounce(for: .seconds(0.1), scheduler: backgroundQueue)
            .map { [weak self] (allSpecies: [Species], searchText: String, sortOptions: SortOptions, favorites: Set<Species.Id>) -> ([SectionGroup: [Species]], [SectionGroup]) in
                guard let self = self else { return ([:], []) }

                logger.debug("start filtering bird list: \(allSpecies.count)")

                // Filter species
                let favoriteFilter: (Species) -> Bool
                if self.filters.list.keys.contains(.favorites) {
                    favoriteFilter = { bird in
                        favorites.contains(bird.speciesId)
                    }
                } else {
                    favoriteFilter = { _ in true }
                }
                let filtered: [Species] = allSpecies
                    .filter({ favoriteFilter($0) && $0.categoryMatches(filters: self.filters.list) && $0.nameMatches(searchText)})
                logger.debug("filtering bird list done: \(filtered.count)")

                let groupedBirds: [SectionGroup: [Species]]
                let sortedGroups: [SectionGroup]
                let groupOption = sortOptions.column
                logger.debug("group according to \(groupOption.rawValue, privacy: .public)")
                if case .filterType(let type) = groupOption {
                    let groupedBirdsByFilter = Dictionary(
                        grouping: filtered,
                        by: { (species: Species) -> Filter in
                            species.filterValue(type) ?? Filter.undefined
                        }
                    )
                    let filterGroups = groupedBirdsByFilter.keys
                    sortedGroups = filterGroups.sorted().map { SectionGroup(id: $0.uniqueFilterId, name: $0.name) }
                    let uniqueKeysWithValues = groupedBirdsByFilter.map { entry -> (key: SectionGroup, value: [Species]) in
                        let (filter, value) = entry
                        return (key: SectionGroup(id: filter.uniqueFilterId, name: filter.name), value: value)
                    }
                    groupedBirds = Dictionary(uniqueKeysWithValues: uniqueKeysWithValues)
                } else {
                    groupedBirds = Dictionary(
                        grouping: filtered,
                        by: { (species: Species) -> SectionGroup in
                            let name = String(species.name.first ?? "#")
                            return SectionGroup(id: name, name: name)
                        }
                    )
                    sortedGroups = groupedBirds.keys.sorted()
                }
                logger.debug("grouping done: \(groupedBirds.keys.count) groups")

                return (groupedBirds, sortedGroups)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (groupedBirds, groups) in
                logger.debug("Storing bird list and triggering redraw")
                self?.objectWillChange.send()
                self?.groupedBirds = groupedBirds
                self?.groups = groups
            })
            .store(in: &cancellables)
    }

    var initialLoadRunning: Bool {
        Filter.allFiltersGrouped.isEmpty || self.allSpecies.isEmpty
    }

    func getHeadShot(for bird: Species, at scale: Int = 2) -> AnyPublisher<UIImage?, Never> {
        if let image = headShotsCache[bird.speciesId] {
            //logger.debug("\(#function): \(bird.speciesId) returning existing image")
            return Just(image).eraseToAnyPublisher()
        }
        logger.debug("\(#function): \(bird.speciesId) fetching image")
        return VdsAPI
            .getSpecieHeadshot(for: bird.speciesId, scale: max(scale, Int(UIScreen.main.scale)))
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
        logger.debug("\(#function)(showAlways: \(showAlways))")

        // No need to refetch the data if we already checked today...
        if let lastCheckDate = birdOfTheDayCheckDate,
           Calendar.current.startOfDay(for: Date()) <= lastCheckDate {
            logger.debug("  already checked on \(lastCheckDate))")
            if showAlways {
                self.showBirdOfTheDayNow()
            }
            return
        }

        // Fetch the bird of the day
        let logger = self.logger
        VdsAPI
            .getBirdOfTheDaySpeciesIDandURL()
            .map {Optional.some($0)}
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] result in
                    if case .failure(let error) = result {
                        self?.error = error
                        logger.error("getBirdOfTheDaySpeciesIDandURL: error \(error.localizedDescription, privacy: .public)")
                        self?.birdOfTheDay = nil
                    }
                },
                receiveValue: { [weak self] (birdOfTheDay) in
                    guard let self = self else { return }

                    logger.debug("getBirdOfTheDaySpeciesIDandURL returned \(birdOfTheDay?.speciesID.description ?? "nil"))")
                    self.birdOfTheDay = birdOfTheDay
                    self.birdOfTheDayCheckDate = Date()
                    if let botd = birdOfTheDay {
                        let currentBirdOfTheDay = botd.speciesID
                        let isNewBirdOfTheDay = (currentBirdOfTheDay > -1 && self.previousBirdOfTheDay != currentBirdOfTheDay)

                        // Make sure we fetch the image
                        if isNewBirdOfTheDay {
                            self.birdOfTheDayImage = nil
                        }
                        if showAlways || isNewBirdOfTheDay {
                            self.showBirdOfTheDayNow()
                        }
                        if isNewBirdOfTheDay {
                            self.refreshWidget()
                        }
                    }
                })
            .store(in: &cancellables)
    }

    private func refreshWidget() {
        logger.debug(#function)
        WidgetCenter.shared.reloadTimelines(ofKind: "BirdOfTheDayWidget")
    }

    func getBirdOfTheDay() {
        guard let (url, speciesId) = birdOfTheDay else {
            logger.debug("\(#function): bail out, du to unknown bird of the day")
            return
        }
        logger.debug("\(#function): fetching image for bird of the day (\(speciesId))")
        VdsAPI
            .getBirdOfTheDay(for: speciesId, from: url)
            .map { [weak self] url in
                let image = UIImage(contentsOfFile: url.path)
                self?.headShotsCache[-speciesId] = image
                return image
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self, logger] (result) in
                    if case .failure(let error) = result {
                        self?.error = error
                        logger.error("getBirdOfTheDay: error \(error.localizedDescription, privacy: .public)")
                        self?.birdOfTheDayImage = nil
                    }
                },
                receiveValue: { [weak self] (image) in
                    self?.birdOfTheDayImage = image
                })
            .store(in: &cancellables)
    }

    func stopEditing() {
        if isEditingSearchField {
            isEditingSearchField = false
        }
    }

    func showBird(_ species: Species) {
        logger.debug("\(#function): \(species.speciesId)")
        stopEditing()

        withAnimation {
            navigationState.mainNavigation = .birdDetails(species)
        }
    }

    func showFilter() {
        logger.debug(#function)
        stopEditing()

        withAnimation {
            navigationState.mainNavigation = .filterList
        }
    }

    func showSortOptions() {
        logger.debug(#function)
        stopEditing()

        withAnimation {
            navigationState.mainNavigation = .sortOptions
        }
    }

    func showBirdOfTheDayNow() {
        logger.debug(#function)
        stopEditing()

        withAnimation {
            navigationState.mainNavigation = nil
            showBirdOfTheDay = true
        }
    }

    /// Returns the number of all species which would currently match the active filters
    func countFilterMatches() -> Int {
        logger.debug(#function)
        let favoriteFilter: (Species) -> Bool
        if self.filters.list.keys.contains(.favorites) {
            favoriteFilter = favoritesManager.isFavorite
        } else {
            favoriteFilter = { _ in true }
        }
        return allSpecies.filter { favoriteFilter($0) && $0.categoryMatches(filters: filters.list)}.count
    }
}

extension AppState: CustomStringConvertible {
    var description: String {
        return "ApplicationState(searchText=\(searchText), navigationState=\(String(describing: navigationState)), activeFilters=\(filters), restorableFilters=\(String(describing: restorableFilters)), previousBirdOfTheDay=\(previousBirdOfTheDay), showBirdOfTheDay=\(showBirdOfTheDay), sortOptions=\(sortOptions))"
    }
}

// Save and restore state in UserActivity
extension AppState {

    func restore(from activity: NSUserActivity) {
        logger.debug("\(#function)(from: \(activity.activityType, privacy: .public))")
        guard activity.activityType == Bundle.main.activityType,
            let stateArray: [String: Any] = activity.userInfo as? [String: Any]
            else { return }

        if let searchText = stateArray[Key.searchText] as? String {
            self.searchText = searchText
        }
        if let restoredFilters = stateArray[Key.activeFilters] as? [String: [Filter.Id]] {
            self.restorableFilters = restoredFilters
        }
        if let previousBirdOfTheDay = stateArray[Key.previousBirdOfTheDay] as? Int {
            self.previousBirdOfTheDay = previousBirdOfTheDay
        }

        // Restore latest navigation
        if let selectedNavigationLinkData = stateArray[Key.selectedNavigationLink] as? Data,
           let selectedNavigationLink = try? JSONDecoder().decode(NavigationState.MainNavigationLinkTarget.self, from: selectedNavigationLinkData) {
            self.navigationState.mainNavigation = selectedNavigationLink
        }

//        if let sortByColumn = stateArray[Key.sortByColumn] as? SortOptions.SortColumn.RawValue,
//           let columnOption = SortOptions.SortColumn(rawValue: sortByColumn)
//        {
//            self.sortOptions.column = columnOption
//        }

        logger.debug("\(#function)(from: \(activity.activityType, privacy: .public)): \(self.description, privacy: .public)")
    }

    func store(in activity: NSUserActivity) {
        logger.debug("\(#function)(in: \(activity.activityType, privacy: .public))")
        var storableList = [String: [Filter.Id]]()
        self.filters.list.forEach { (key: FilterType, value: [Filter.Id]) in
            storableList[key.rawValue] = value
        }
        let selectedNavigationLinkData = (try? JSONEncoder().encode(navigationState.mainNavigation)) ?? Data()

        let stateArray: [String: Any] = [
            Key.searchText: searchText,
            Key.activeFilters: storableList,
            Key.selectedNavigationLink: selectedNavigationLinkData,
            Key.previousBirdOfTheDay: previousBirdOfTheDay as Species.Id
        ]
        activity.addUserInfoEntries(from: stateArray)

        logger.debug("\(#function)(in: \(activity.activityType, privacy: .public)): \(self.description, privacy: .public)")
    }

    private enum Key {
        static let searchText = "searchText"
        static let activeFilters = "activeFilters"
        static let previousBirdOfTheDay = "previousBirdOfTheDay"
        static let selectedNavigationLink = "selectedNavigationLink"
        static let sortByColumn = "sortByColumn"
    }
}

extension AppState {
    func handleUserActivity(_ userActivity: NSUserActivity) {
        logger.debug("\(#function)(\(userActivity.activityType, privacy: .public)): \(self.description)")

        if userActivity.activityType == NSUserActivity.showBirdActivityType {
            guard let birdID = userActivity.userInfo?[NSUserActivity.ActivityKeys.birdID.rawValue] as? Int
            else {
                logger.error("Missing parameter birdID for (\(userActivity.activityType, privacy: .public))")
                return
            }

            logger.debug("handleUserActivity: birdID=\(birdID)")
            if let bird = Species.species(for: birdID) {
                self.showBird(bird)
            }
        } else if userActivity.activityType == NSUserActivity.showBirdTheDayActivityType {
            logger.debug("handleUserActivity: showing bird of the day \(self.birdOfTheDay.debugDescription, privacy: .public)")
            self.checkBirdOfTheDay(showAlways: true)
        } else {
            logger.debug("handleUserActivity: Skipping unsupported \(userActivity.activityType, privacy: .public)")
            return
        }
        logger.debug("\(#function)(\(userActivity.activityType, privacy: .public)): current state \(self.description, privacy: .public)")
    }

    @discardableResult
    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        logger.debug("\(#function)(\(shortcutItem.type, privacy: .public))")

        if shortcutItem.type == "BirdOfTheDay" {
            let appState = AppState.shared
            appState.checkBirdOfTheDay(showAlways: true)
            return true
        }
        return false
    }
}
