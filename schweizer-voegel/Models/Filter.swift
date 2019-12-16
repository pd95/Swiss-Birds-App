//
//  Filter.swift
//  schweizer-voegel
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

enum FilterType: String, CaseIterable {
    case haeufigeart = "filterhaeufigeart"
    case lebensraum = "filterlebensraum"
    case nahrung = "filternahrung"
    case roteListe = "filterrotelistech"
    case entwicklungatlas = "filterentwicklungatlas"
    case vogelgruppe = "filtervogelguppe"
}

struct Filter: Identifiable, Equatable, Hashable {
    let id = UUID()

    let filterId: Int
    let name : String
    let type : FilterType

    var uniqueFilterId : String {
        get {
            return "\(type.rawValue)-\(filterId)"
        }
    }
}
