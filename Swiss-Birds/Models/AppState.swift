//
//  AppState.swift
//  Swiss-Birds
//
//  Created by Philipp on 18.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI
import Combine

final class AppState : ObservableObject {

    @Published var birdOfTheDay: VdsAPI.BirdOfTheDayData?
    @Published var image: UIImage?

    @Published var showBirdOfTheDay: Bool = false

    @Published var loadImage: Bool = false

    var checkBirdOfTheDayCancellable: AnyCancellable?

    func checkBirdOfTheDay() {
        // Fetch the bird of the day
        checkBirdOfTheDayCancellable = VdsAPI
            .getBirdOfTheDaySpeciesIDandURL()
            .map {Optional.some($0)}
            //.replaceError(with: nil)     // **FIXME** Bug in Combine causes a memory leak
            .receive(on: DispatchQueue.main)
            .print()
            .sink(
                receiveCompletion: { (result) in
                    print(result)
                },
                receiveValue: { [unowned self] (birdOfTheDay) in
                    self.birdOfTheDay = birdOfTheDay
                    self.showBirdOfTheDay = true
                })
    }

    var getBirdOfTheDayCancellable: AnyCancellable?
    func getBirdOfTheDay() {
        guard loadImage, let speciesId = birdOfTheDay?.speciesID else {
            return
        }
        getBirdOfTheDayCancellable = VdsAPI
            .getBirdOfTheDay(for: speciesId)
            .map { data in
                let image = UIImage(data: data)
                return image
            }
            .replaceError(with: UIImage(named: "placeholder-headshot")) // **FIXME** Bug in Combine causes a memory leak
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { (result) in
                    print(result)
                },
                receiveValue: { [unowned self] (image) in
                    self.image = image
                })
    }
}
