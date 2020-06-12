//
//  BirdDetailViewModel.swift
//  Swiss-Birds
//
//  Created by Philipp on 08.06.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Combine
import SwiftUI

class BirdDetailViewModel: ObservableObject {

    typealias UIImagePublisher = AnyPublisher<(Int, UIImage?), Never>

    let birdService : BirdService
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

    var cancellables = Set<AnyCancellable>()

    init(bird: Species, birdService: BirdService) {
        self.bird = bird
        self.birdService = birdService
    }

    func fetchData() {
        birdService
            .getSpecie(for: bird.speciesId)
            .map { d -> VdsSpecieDetail? in d }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.error = error
                    }
                },
                receiveValue: { details in
                if let details = details {
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

                    self.details = details
                }
            })
            .store(in: &cancellables)

        $imageDetails
            .flatMap { imageDetails -> AnyPublisher<[(Int, UIImage?)], Never> in
                // Generate publisher for each missing image
                let publishers = imageDetails
                    .filter{ $0.image == nil }
                    .map({ imageDetail -> UIImagePublisher in
                        self.fetchImage(imageDetail: imageDetail)
                    })

                let sequence = Publishers.Sequence<[UIImagePublisher], Never>(sequence: publishers)
                return sequence.flatMap{ $0 }.collect()
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { result in
                result.forEach { (element) in
                    let (index, image) = element
                    if self.imageDetails[index].image == nil && image != nil {
                        self.imageDetails[index].image = image
                    }
                }
                self.objectWillChange.send()
                print("\(result.count) images load")
            })
            .store(in: &cancellables)

        // Fetch voice data 1s after details have been load
        $imageDetails
            .compactMap({ $0.first })
            .filter({ $0.image != nil})
            .setFailureType(to: BirdService.APIError.self)
            .flatMap { imageDetails -> AnyPublisher<Data?, BirdService.APIError> in
                return self.birdService.getVoice(for: self.bird.speciesId)
                    .map { (d: Data) -> Data? in d }
                    .eraseToAnyPublisher()
            }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .assign(to: \.voiceData, on: self)
            .store(in: &cancellables)
    }

    private func fetchImage(imageDetail: ImageDetails) -> UIImagePublisher {
        birdService.getSpecieImage(for: self.bird.speciesId, number: imageDetail.index)
            .replaceError(with: nil)
            .map { (image: UIImage?) -> (Int, UIImage?) in
                return (imageDetail.index, image)
            }
            .eraseToAnyPublisher()
    }
}
