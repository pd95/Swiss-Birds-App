//
//  Filter.swift
//  schweizer-voegel
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

enum FilterType: String, CaseIterable, CustomStringConvertible {
    
    case haeufigeart = "filterhaeufigeart"
    case lebensraum = "filterlebensraum"
    case nahrung = "filternahrung"
    case vogelgruppe = "filtervogelguppe"
    case roteListe = "filterrotelistech"
    case entwicklungatlas = "filterentwicklungatlas"
    
    var description: String {
        switch (self) {
        case .lebensraum: return "Lebensraum"
        case .nahrung: return "Nahrung"
        case .haeufigeart: return "Häufige Art"
        case .roteListe: return "Rote Liste"
        case .vogelgruppe: return "Vogel Gruppe"
        case .entwicklungatlas: return "Entwicklung"
        }
    }
}

struct Filter: Identifiable, Equatable {
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
