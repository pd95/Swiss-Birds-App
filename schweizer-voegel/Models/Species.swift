//
//  Arten.swift
//  schweizer-voegel
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

struct Species: Identifiable, Hashable {
    let id = UUID()

    let speciesId : Int
    let name : String
    let alternateName : String
    
    let filterMap : [FilterType: [Int]]  // For each FilterType an array of related IDs

    var isCommon : Bool {
        return filterMap[.haeufigeart]![0] == 0
    }
    
    var group : Int {
        return filterMap[.vogelgruppe]![0]
    }
    
    var groupImageName : String {
        return "\(FilterType.vogelgruppe.rawValue)-\(group)"
    }
    
    var breadCrumbImageName : String {
        return "\(speciesId)"
    }

    var primaryPictureName : String {
        return "\(speciesId)_0"
    }

    var secondaryPictureName : String {
        return "\(speciesId)_1"
    }

    func matchesSearch(for text: String) -> Bool {
        if text.count == 0 {
            return true
        }
        return name.lowercased().contains(text.lowercased())
    }
}
