//
//  Arten.swift
//  Swiss-Birds
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

struct Species: Identifiable, Hashable, CustomStringConvertible {
    typealias Id = Int

    let id = UUID()

    let speciesId : Id
    let name : String
    let alternateName : String
    
    let filterMap : FilterList  // For each FilterType an array of related IDs

    func filterSymbolName(_ filterType : FilterType) -> String {
        if let array = filterMap[filterType], array.count > 0 {
            return "\(filterType.rawValue)-\(array[0])"
        }
        return ""
    }

    func filterValue(_ filterType : FilterType) -> Filter? {
        if let filterId = filterMap[filterType]?.first {
            return Filter.filter(forId: filterId, ofType: filterType)
        }
        return nil
    }

    func nameMatches(_ text: String) -> Bool {
        if text.isEmpty {
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
    
    func categoryMatches(filters: FilterList) -> Bool {
        if filters.isEmpty {
            return true
        }
        
        var matchesAll = true
        for (type, relevantIds) in filters {
            matchesAll = matchesAll && (filterMap[type] ?? []).reduce(false, { $0 || relevantIds.contains($1)})
        }
        
        return matchesAll
    }
    
    var description: String {
        return "Species(speciesId=\(speciesId), name=\(name), filterMap=\(filterMap))"
    }
}
