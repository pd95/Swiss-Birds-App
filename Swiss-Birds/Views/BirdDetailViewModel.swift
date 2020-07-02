//
//  BirdDetailViewModel.swift
//  Swiss-Birds
//
//  Created by Philipp on 08.06.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Combine
import os.log
import SwiftUI

class BirdDetailViewModel: ObservableObject {

    typealias UIImagePublisher = AnyPublisher<(Int, UIImage?), Error>

    let bird: Species

    @Published var details : VdsSpecieDetail?
    @Published var imageDetails = [ImageDetails]()
    @Published var voiceData: Data?
    @Published var error: Error?

    struct ImageDetails: Identifiable {
        let id: UUID = UUID()
        let index: Int
        var image: UIImage?
        let author: String
        let description: String
    }

    init(bird: Species) {
        self.bird = bird
    }

    var getSpecieCancellable: AnyCancellable?
    var getImageDetailsCancellable: AnyCancellable?
    var getVoiceCancellable: AnyCancellable?

    func fetchData() {
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
                        os_log("getSpecie error: %{Public}@", error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] details in
                    guard let self = self else { return }
                    if let details = details {
                        self.details = details

                        var imageDetails = [ImageDetails]()
                        if let author = details.autor0, let description = details.bezeichnungDe0, !author.isEmpty{
                            imageDetails.append(.init(index: 0, image: nil, author: author, description: description))
                        }
                        if let author = details.autor1, let description = details.bezeichnungDe1, !author.isEmpty{
                            imageDetails.append(.init(index: 1, image: nil, author: author, description: description))
                        }
                        if let author = details.autor2, let description = details.bezeichnungDe2, !author.isEmpty{
                            imageDetails.append(.init(index: 2, image: nil, author: author, description: description))
                        }
                        self.imageDetails = imageDetails
                    }
                })

        getImageDetailsCancellable = $details
            .compactMap {$0}
            .receive(on: DispatchQueue.main)
            .map { [unowned self] in _ = $0 ; return self.imageDetails }
            .setFailureType(to: Error.self)
            .flatMap {[unowned self] (imageDetails: [ImageDetails]) -> AnyPublisher<[(Int, UIImage?)], Error> in
                // Generate publisher for each missing image
                let publishers = imageDetails
                    .filter{ $0.image == nil }
                    .map({ imageDetail -> UIImagePublisher in
                        self.fetchImage(imageDetail: imageDetail)
                    })

                let sequence = Publishers.Sequence<[UIImagePublisher], Error>(sequence: publishers)
                return sequence.flatMap{ $0 }.collect()
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.error = error
                        os_log("fetch imageDetails error: %{Public}@", error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] result in
                    guard let self = self else { return }
                    var imageDetails = self.imageDetails
                    result.forEach { element in
                        let (index, image) = element
                        if imageDetails[index].image == nil && image != nil {
                            imageDetails[index].image = image
                        }
                    }
                    self.imageDetails = imageDetails
                    self.objectWillChange.send()
                })

        // Fetch voice data 1s after details have been load
        getVoiceCancellable = $imageDetails
            .compactMap({ $0.first })
            .filter({ $0.image != nil})
            .setFailureType(to: Error.self)
            .flatMap { imageDetails -> AnyPublisher<Data?, Error> in
                VdsAPI.getVoice(for: speciesId)
                    .map { (d: Data) -> Data? in d }
                    .eraseToAnyPublisher()
            }
            //.replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            //.assign(to: \.voiceData, on: self)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        os_log("fetch voiceData error: %{Public}@", error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] data in
                    guard let self = self else { return }
                    self.voiceData = data
            })
    }

    private func fetchImage(imageDetail: ImageDetails) -> UIImagePublisher {
        VdsAPI.getSpecieImage(for: bird.speciesId, number: imageDetail.index)
            .map { UIImage(data: $0) }
            //.replaceError(with: nil)
            .map { (image: UIImage?) -> (Int, UIImage?) in
                return (imageDetail.index, image)
            }
            .eraseToAnyPublisher()
    }
}
