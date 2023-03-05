//
//  NameLanguage.swift
//  SpeciesCore
//
//  Created by Philipp on 22.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

public enum NameLanguage: String {
    case german = "de", french = "fr", italian = "it", rhaetoRoman = "rr"
    case english = "en", spanish = "es", dutch = "du"
}

extension NameLanguage: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        guard let language = NameLanguage(rawValue: value) else {
            fatalError("Invalid language \(value)")
        }
        self = language
    }
}