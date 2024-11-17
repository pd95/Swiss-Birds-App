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

    private let logger = Logger(subsystem: "DataFetcher", category: "general")

    private var birdOfTheDaySubscriber: AnyCancellable?
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard, restoreCache: Bool = true) {
        logger.log("DataFetcher.\(#function) start")
        self.defaults = defaults
        if restoreCache, let data = defaults.data(forKey: "BirdOfTheDayData") {
            do {
                let bod = try JSONDecoder().decode(BirdOfTheDay.self, from: data)
                if FileManager.default.fileExists(atPath: bod.fileURL.relativePath) {
                    logger.log("DataFetcher.\(#function) keeping existing bird of the day")
                    result = bod
                }
            } catch {
                logger.error("Decoding BirdOfTheDay data: \(error.localizedDescription)")
            }
        }
        logger.log("DataFetcher.\(#function) end")
    }

    var result: BirdOfTheDay? {
        didSet {
            logger.log("\(#function) set new result")
            if let result {
                do {
                    let data = try JSONEncoder().encode(result)
                    defaults.set(data, forKey: "BirdOfTheDayData")
                } catch {
                    logger.error("Storing BirdOfTheDay data: \(error.localizedDescription)")
                }
            }
        }
    }

    private var reloadDate: Date {
        let now = Date()
        if let loadingDate = result?.loadingDate {
            let tomorrow = Calendar.current.date(byAdding: DateComponents(day: 1), to: loadingDate) ?? now.addingTimeInterval(24*60*60)
            let reloadDate = Calendar.current.startOfDay(for: tomorrow)
            logger.log("🔴 reloadDate = \(reloadDate) (midnight after load date)")
            return reloadDate
        }
        logger.log("🔴 reloadDate = \(now) (now)")
        return now
    }

    private var getBirdOfTheDayCompletionHandlers = [(BirdOfTheDay)->Void]()

    private var fakeBackdatedLoad: Bool = false /*{
        fakeItUntilDate > Date()
    }
    private var fakeItUntilDate = Date().addingTimeInterval(60)
*/

    private func fetchBirdOfTheDay() {
        logger.info("fetchBirdOfTheDay")
        guard birdOfTheDaySubscriber == nil else {
            logger.info("  fetch already running...")
            return
        }

        let logger = self.logger
        result = nil
        birdOfTheDaySubscriber = VdsAPI.getBirdOfTheDaySpeciesIDandURL()
            .map { (birdOfTheDayData: VdsAPI.BirdOfTheDayData) in
                if self.fakeBackdatedLoad {
                    return (url: VdsAPI.base, speciesID: 1200)
                }
                return birdOfTheDayData
            }
            .handleEvents(receiveOutput: { (birdOfTheDayData: VdsAPI.BirdOfTheDayData) in
                logger.debug("speciesID: \(birdOfTheDayData.speciesID), url: \(birdOfTheDayData.url)")
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
                logger.info("fetchBirdOfTheDay: \(result)")
                if let completionHandlers = self?.getBirdOfTheDayCompletionHandlers {
                    completionHandlers.forEach { self?.getBirdOfTheDay(completion: $0) }
                    self?.getBirdOfTheDayCompletionHandlers.removeAll()
                }
                self?.birdOfTheDaySubscriber = nil
            } receiveValue: { [weak self] (result) in
                self?.result = result
                logger.debug("fetchBirdOfTheDay: finished now, lastLoadingDate=\(result.loadingDate)")
            }
    }

    func getBirdOfTheDay(completion: @escaping (BirdOfTheDay) -> Void) {
        logger.log("\(#function) start")
        guard let result,
              reloadDate > Date()
        else {
            logger.info("getBirdOfTheDay: fetching new data")
            getBirdOfTheDayCompletionHandlers.append(completion)
            fetchBirdOfTheDay()
            logger.log("\(#function) end while fetching new data")
            return
        }
        logger.info("getBirdOfTheDay: returning existing data \(result.speciesID)")
        completion(result)
        logger.log("\(#function) end reusing existing data")
    }
}

extension Subscribers.Completion: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
            case .finished:
                return "finished"
            case .failure(let error):
                return "failure(\(error.localizedDescription)"
        }
    }
}
