//
//  DataFetcher.swift
//  SwissBirds
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

    private var birdOfTheDaySubscriber: AnyCancellable?
    private var getSpecieSubscriber: AnyCancellable?

    private var cancellables = Set<AnyCancellable>()

    var result: BirdOfTheDay?
    var lastLoadingDate: Date {
        result?.loadingDate ?? .distantPast
    }

    var finishedLoading: Bool {
        result != nil
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

        result = nil
        birdOfTheDaySubscriber = VdsAPI.getBirdOfTheDaySpeciesIDandURL()
            .map { (birdOfTheDayData: VdsAPI.BirdOfTheDayData) in
                if self.fakeBackdatedLoad {
                    return (url: VdsAPI.base, speciesID: 1200)
                }
                return birdOfTheDayData
            }
            .handleEvents(receiveOutput: { [weak self] (birdOfTheDayData: VdsAPI.BirdOfTheDayData) in
                self?.logger.debug("speciesID: \(birdOfTheDayData.speciesID), url: \(birdOfTheDayData.url)")
            })
            .flatMap({ (birdOfTheDayData: VdsAPI.BirdOfTheDayData) -> AnyPublisher<(speciesID: Int, remoteURL: URL, fileURL: URL), Error> in
                VdsAPI.getBirdOfTheDay(for: birdOfTheDayData.speciesID, from: birdOfTheDayData.url)
                    .map({ url in
                        (birdOfTheDayData.speciesID, birdOfTheDayData.url, url)
                    })
                    .eraseToAnyPublisher()
            })
            .flatMap({ result -> AnyPublisher<(speciesID: Int, name: String, remoteURL: URL, fileURL: URL), Error> in
                return VdsAPI.getSpecie(for: result.speciesID)
                    .map({ (result.speciesID, $0.artname, result.remoteURL, result.fileURL) })
                    .eraseToAnyPublisher()
            })
            .map { result -> BirdOfTheDay in
                let lastLoadingDate = self.fakeBackdatedLoad ? Date().addingTimeInterval(60-24*60*60) : Date()
                return BirdOfTheDay(speciesID: result.speciesID, name: result.name, remoteURL: result.remoteURL, fileURL: result.fileURL, loadingDate: lastLoadingDate)
            }
            .subscribe(on: RunLoop.main)
            .sink { [weak self] (result) in
                self?.logger.info("fetchBirdOfTheDay: \(result)")
                if let completionHandlers = self?.getBirdOfTheDayCompletionHandlers {
                    completionHandlers.forEach { self?.getBirdOfTheDay(completion: $0) }
                    self?.getBirdOfTheDayCompletionHandlers.removeAll()
                }
                self?.birdOfTheDaySubscriber = nil
            } receiveValue: { [weak self] (result) in
                guard let self = self else { return }
                self.result = result
                self.logger.debug("fetchBirdOfTheDay: finished now, lastLoadingDate=\(result.loadingDate)")
            }
    }

    func getBirdOfTheDay(completion: @escaping (BirdOfTheDay) -> Void) {
        guard let result,
              reloadDate > Date()
        else {
            logger.info("getBirdOfTheDay: fetching new data")
            getBirdOfTheDayCompletionHandlers.append(completion)
            fetchBirdOfTheDay()
            return
        }
        logger.info("getBirdOfTheDay: returning existing data \(result.speciesID)")
        completion(result)
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
