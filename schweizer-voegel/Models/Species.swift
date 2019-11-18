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
    
    var breadCrumbImageName : String {
        return "\(speciesId)"
    }

    var primaryPictureName : String {
        return "\(speciesId)_0"
    }

    var secondaryPictureName : String {
        return "\(speciesId)_1"
    }

    func filterSymbolName(_ filterType : FilterType) -> String {
        if let array = filterMap[filterType], array.count > 0 {
            return "\(filterType.rawValue)-\(array[0])"
        }
        return ""
    }
    
    func nameMatches(_ text: String) -> Bool {
        if text.count == 0 {
            return true
        }
        let lowercaseName = name.lowercased() + " " + alternateName.lowercased()
        for word in text.lowercased().split(separator: " ") {
            if lowercaseName.contains(word) {
                return true
            }
        }
        return false
    }
    
    func categoryMatches(filters: [FilterType: [Int]]) -> Bool {
        if filters.count == 0 {
            return true
        }
        
        var matchesAll = true
        for (type, relevantIds) in filters {
            matchesAll = matchesAll && (filterMap[type] ?? []).reduce(false, { $0 || relevantIds.contains($1)})
        }
        
        return matchesAll
    }
}
