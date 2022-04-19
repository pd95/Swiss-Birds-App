//
//  Species.swift
//  SpeciesCore
//
//  Created by Philipp on 15.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation

public struct Species: Identifiable {
    public let id: Int

    public let name: String
    public let synonyms: String
    public let alias: String
    public let voiceData: Bool

    public let filters: Set<Filter>

    public init(id: Int, name: String, synonyms: String, alias: String, voiceData: Bool, filters: Set<Filter> = .init()) {
        self.id = id
        self.name = name
        self.synonyms = synonyms
        self.alias = alias
        self.voiceData = voiceData
        self.filters = filters
    }
}

extension Species: Equatable, Hashable {
    public static func == (lhs: Species, rhs: Species) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
