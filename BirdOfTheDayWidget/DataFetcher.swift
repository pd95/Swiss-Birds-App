//
//  DataFetcher.swift
//  Swiss-Birds
//
//  Created by Philipp on 26.10.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation
import Combine
import UIKit
import os.log

class DataFetcher: ObservableObject {
    static let shared = DataFetcher()

    let logger = Logger(subsystem: "DataFetcher", category: "general")

    typealias BirdOfTheDay = (speciesID: Int, name: String, image: UIImage, validDate: Date)

    private var birdOfTheDaySubscriber: AnyCancellable?
    private var getSpecieSubscriber: AnyCancellable?

    private var cancellables = Set<AnyCancellable>()

    @Published var speciesID: Int?
    @Published var name: String?
    @Published var image: UIImage?
    @Published var lastLoadingDate: Date = .distantPast

    init() {
        fetchBirdOfTheDay()
    }

    var finishedLoading: Bool {
        speciesID != nil &&
            name != nil &&
            image != nil
    }

    var reloadDate: Date {
        let now = Date()
        if finishedLoading {
            let tomorrow = Calendar.current.date(byAdding: DateComponents(day: 1), to: lastLoadingDate) ?? now.addingTimeInterval(24*60*60)
            let reloadDate = Calendar.current.startOfDay(for: tomorrow)
            logger.log("🔴 reloadDate = \(reloadDate) (tomorrow)")
            return reloadDate
        }
        logger.log("🔴 reloadDate = \(now) (now)")
        return now
    }

    enum FetchError: Error {
        case failed
    }

    private var getBirdOfTheDayCompletionHandlers = [(BirdOfTheDay)->Void]()

    private var fakeBackdatedLoad: Bool = false /*{
        fakeItUntilDate > Date()
    }
    private var fakeItUntilDate = Date().addingTimeInterval(60)
*/

    func fetchBirdOfTheDay() {
        logger.info("fetchBirdOfTheDay")
        guard birdOfTheDaySubscriber == nil else {
            logger.info("  fetch already running...")
            return
        }

        speciesID = nil
        name = nil
        image = nil
        birdOfTheDaySubscriber = VdsAPI.getBirdOfTheDaySpeciesIDandURL()
            .map { (birdOfTheDayData: VdsAPI.BirdOfTheDayData) in
                if self.fakeBackdatedLoad {
                    return (url: VdsAPI.base, speciesID: 1200)
                }
                return birdOfTheDayData
            }
            .handleEvents(receiveOutput: { [weak self] (birdOfTheDayData: VdsAPI.BirdOfTheDayData) in
                self?.logger.debug("speciesID: \(birdOfTheDayData.speciesID)")
                self?.speciesID = birdOfTheDayData.speciesID
             })
            .flatMap({ (birdOfTheDayData: VdsAPI.BirdOfTheDayData) -> AnyPublisher<UIImage?, Error> in
                VdsAPI.getBirdOfTheDay(for: birdOfTheDayData.speciesID)
                    .map { UIImage(data: $0) }
                    .handleEvents(receiveOutput: { [weak self] (image: UIImage?) in
                        self?.logger.debug("image: \(image != nil)")
                        self?.image = image
                     })
                    .eraseToAnyPublisher()
            })
            .flatMap({ [weak self] _ -> AnyPublisher<String, Error> in
                guard let speciesID = self?.speciesID else {
                    return Fail(error: FetchError.failed as Error)
                        .eraseToAnyPublisher()
                }
                return VdsAPI.getSpecie(for: speciesID)
                    .map(\.artname)
                    .handleEvents(receiveOutput: { [weak self] (name) in
                        self?.logger.debug("name: \(name)")
                        self?.name = name
                     })
                    .eraseToAnyPublisher()
            })
            .sink { [weak self] (result) in
                self?.logger.info("fetchBirdOfTheDay: \(result)")
                if let completionHandlers = self?.getBirdOfTheDayCompletionHandlers {
                    completionHandlers.forEach { self?.getBirdOfTheDay(completion: $0) }
                    self?.getBirdOfTheDayCompletionHandlers.removeAll()
                }
                self?.birdOfTheDaySubscriber = nil
            } receiveValue: { [weak self] (_) in
                guard let self = self else { return }
                self.lastLoadingDate = self.fakeBackdatedLoad ? Date().addingTimeInterval(60-24*60*60) : Date()
                self.logger.debug("fetchBirdOfTheDay: finished now, lastLoadingDate=\(self.lastLoadingDate)")
            }
    }

    func getBirdOfTheDay(completion: @escaping (BirdOfTheDay) -> Void) {
        guard let speciesID = speciesID,
              let name = name,
              let image = image,
              reloadDate > Date()
        else {
            logger.info("getBirdOfTheDay: fetching new data")
            getBirdOfTheDayCompletionHandlers.append(completion)
            fetchBirdOfTheDay()
            return
        }
        logger.info("getBirdOfTheDay: returning existing data \(speciesID)")
        completion((speciesID, name, image, reloadDate))
    }
}

extension Subscribers.Completion: CustomStringConvertible {
    public var description: String {
        switch self {
            case .finished:
                return "finished"
            case .failure(let error):
                return "failure(\(error.localizedDescription)"
        }
    }
}
