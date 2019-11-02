//
//  Filter.swift
//  schweizer-voegel
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

enum FilterType: String, Decodable, CaseIterable, CustomStringConvertible {
    
    case lebensraum = "filterlebensraum"
    case nahrung = "filternahrung"
    case haeufigeart = "filterhaeufigeart"
    case roteListe = "filterrotelistech"
    case vogelgruppe = "filtervogelguppe"
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

struct Filter: Decodable {
    let id : Int
    let name : String
    let type : FilterType
    
    var uniqueID : String {
        get {
            return "\(type.rawValue)-\(id)"
        }
    }
}
