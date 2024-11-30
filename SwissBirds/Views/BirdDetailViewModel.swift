//
//  BirdDetailViewModel.swift
//  SwissBirds
//
//  Created by Philipp on 08.06.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Combine
import os.log
import SwiftUI

@MainActor
class BirdDetailViewModel: ObservableObject {

    private let logger = Logger(subsystem: "BirdDetailViewModel", category: "general")

    var bird: Species = .placeholder

    @Published var details: VdsSpecieDetail?
    @Published var imageDetails = [ImageDetails]()
    @Published var voiceData: Data?
    var error: Error? {
        willSet {
            self.objectWillChange.send()
        }
        didSet {
            // Sync error on AppState
            AppState.shared.error = error
        }
    }

    struct ImageDetails: Identifiable {
        let id: UUID = UUID()
        let index: Int
        var image: UIImage?
        let author: String
        let description: String
        var isLoading = true
    }

    func setBird(_ bird: Species) {
        if self.bird.id != bird.id {
            cancelRunningFetches()
            self.bird = bird
            details = nil
            imageDetails = []
            fetchSpeciesDetail()
        }
    }

    deinit {
        logger.info("BirdDetailViewModel.\(#function, privacy: .public)")
    }

    private var getSpecieCancellable: AnyCancellable?
    private var dataTaskGroup: TaskGroup<(Int, UIImage?, Data?)>?

    func cancelRunningFetches() {
        getSpecieCancellable?.cancel()
        dataTaskGroup?.cancelAll()
    }

    func fetchSpeciesDetail() {
        logger.info("BirdDetailViewModel.\(#function, privacy: .public)")
        let speciesId = bird.speciesId
        getSpecieCancellable = VdsAPI
            .getSpecie(for: speciesId)
            .map { d -> VdsSpecieDetail? in d }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    if case .failure(let error) = completion {
                        self.error = error
                        logger.error("getSpecie error: \(error.localizedDescription, privacy: .public)")
                    }
                },
                receiveValue: { [weak self] details in
                    guard let self = self else { return }
                    if let details = details {
                        self.objectWillChange.send()
                        self.details = details

                        var imageDetails = [ImageDetails]()
                        if let author = details.autor0, let description = details.bezeichnungDe0, !author.isEmpty {
                            imageDetails.append(.init(index: 0, image: nil, author: author, description: description))
                        }
                        if let author = details.autor1, let description = details.bezeichnungDe1, !author.isEmpty {
                            imageDetails.append(.init(index: 1, image: nil, author: author, description: description))
                        }
                        if let author = details.autor2, let description = details.bezeichnungDe2, !author.isEmpty {
                            imageDetails.append(.init(index: 2, image: nil, author: author, description: description))
                        }
                        self.imageDetails = imageDetails
                    }
                })
    }


    func fetchData() async {
        let logger = self.logger
        let speciesId = bird.speciesId
        logger.info("BirdDetailViewModel.\(#function, privacy: .public) for \(speciesId)")

        // Cancel all child tasks of running group
        dataTaskGroup?.cancelAll()
        await withTaskGroup(of: (Int, UIImage?, Data?).self) { group in
            self.dataTaskGroup = group
            for imageDetail in imageDetails {
                logger.info("BirdDetailViewModel.\(#function, privacy: .public) adding data task for \(imageDetail.index)")
                group.addTask {
                    do {
                        for try await data in VdsAPI.getSpecieImage(for: speciesId, number: imageDetail.index+1).values {
                            if let image = UIImage(data: data) {
                                return (imageDetail.index, image, nil)
                            }
                        }
                    } catch {
                        logger.error("Error loading image at index \(imageDetail.index): \(error.localizedDescription, privacy: .public)")
                    }
                    return (imageDetail.index, nil, nil)
                }
            }

            if details?.videosBilderStimmen == "1" {
                if SettingsStore.shared.voiceDataOverConstrainedNetworkAccess {
                    logger.info("BirdDetailViewModel.\(#function, privacy: .public) adding data task for \(-1)")
                    group.addTask {
                        do {
                            for try await data in VdsAPI.getVoice(for: speciesId, allowsConstrainedNetworkAccess: SettingsStore.shared.voiceDataOverConstrainedNetworkAccess).values {
                                return (-1, nil, data)
                            }
                        } catch {
                            logger.error("Error loading voice data: \(error.localizedDescription, privacy: .public)")
                        }
                        return (-1, nil, nil)
                    }
                } else {
                    logger.info("BirdDetailViewModel.\(#function, privacy: .public) skipping voice data due to preferences")
                }
            }

            for await (index, image, data) in group {
                logger.info("BirdDetailViewModel.\(#function, privacy: .public): Received result for index \(index) (cancelled = \(Task.isCancelled)).")

                if Task.isCancelled == false {
                    if index == -1 {
                        voiceData = data
                    } else if imageDetails.indices.contains(index) {
                        imageDetails[index].image = image
                        imageDetails[index].isLoading = false
                    }
                }
            }
            self.dataTaskGroup = nil
        }
    }
}
