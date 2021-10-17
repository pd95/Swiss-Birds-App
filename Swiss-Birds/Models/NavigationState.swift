//
//  NavigationState.swift
//  Swiss-Birds
//
//  Created by Philipp on 14.10.21.
//  Copyright © 2021 Philipp. All rights reserved.
//

import Foundation

class NavigationState: ObservableObject {

    // Enumeration of all possible cases of the current selected NavigationLink
    enum MainNavigationLinkTarget: Hashable, Codable {
        case nothing
        case filterList
        case birdDetails(Species)
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
                guard let species = Species.species(for: speciesId) else {
                    throw CodingError.unknownValue
                }
                self = .birdDetails(species)
            case 3:
                self = .sortOptions
            default:
                throw CodingError.unknownValue
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: Key.self)
            switch self {
            case .nothing:
                try container.encode(-1, forKey: .rawValue)
            case .filterList:
                try container.encode(0, forKey: .rawValue)
            case .birdDetails(let species):
                try container.encode(1, forKey: .rawValue)
                try container.encode(species.speciesId, forKey: .associatedValue)
            case .sortOptions:
                try container.encode(3, forKey: .rawValue)
            }
        }
    }

    @Published var mainNavigation: MainNavigationLinkTarget?
}
