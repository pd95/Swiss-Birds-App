//
//  FilterType.swift
//  SpeciesCore
//
//  Created by Philipp on 15.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation

public struct FilterType: Equatable, Hashable, Identifiable {
    public typealias ID = String

    public var id: ID { name }
    public let name: String

    public init(_ value: String) {
        name = value
    }
}

extension FilterType: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        name = value
    }
}
