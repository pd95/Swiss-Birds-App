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
            return tomorrow
        }
        return now
    }

    enum FetchError: Error {
        case failed
    }

    private var getBirdOfTheDayCompletionHandlers = [(BirdOfTheDay)->Void]()

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
                self?.lastLoadingDate = Date()
                self?.logger.debug("fetchBirdOfTheDay: finished now")
            }
    }

    func getBirdOfTheDay(completion: @escaping (BirdOfTheDay)->Void) {
        guard let speciesID = speciesID,
              let name = name,
              let image = image,
              reloadDate > Date()
        else {
            getBirdOfTheDayCompletionHandlers.append(completion)
            fetchBirdOfTheDay()
            return
        }
        completion((speciesID, name, image, reloadDate))
    }
}

extension Subscribers.Completion: CustomStringConvertible{
    public var description: String {
        switch self {
            case .finished:
                return "finished"
            case .failure(let error):
                return "failure(\(error.localizedDescription)"
        }
    }
}
