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

    static fileprivate var speciesMap = [Species.Id : Species]()

    static func species(for speciesId: Species.Id) -> Species? {
        speciesMap[speciesId]
    }
}

func loadSpeciesData(vdsList : [VdsListElement]) -> [Species] {

    var speciesMap = [Species.Id : Species]()

    vdsList.forEach { (item) in
        let speciesID = Species.Id(item.artID)!
        let species = Species(
            speciesId: speciesID,
            name: item.artname,
            alternateName: item.synonyme,
            filterMap: [
                .lebensraum : item.filterlebensraum.split(separator: ";").map({ (s) -> Filter.Id in
                    return Filter.Id(String(s.trimmingCharacters(in: .whitespaces)))!
                }),
                .vogelgruppe : [Filter.Id(item.filtervogelgruppe)!],
                .nahrung : item.filternahrung.split(separator: ";").map({ (s) -> Filter.Id in
                    return Filter.Id(String(s.trimmingCharacters(in: .whitespaces)))!
                }),
                .haeufigeart : [Filter.Id(item.filterhaeufigeart)!],
                .roteListe : (item.filterrotelistech.count > 0 ? [Filter.Id(item.filterrotelistech)!]:[]),
                .entwicklungatlas : (item.filterentwicklungatlas?.count ?? 0 > 0 ? [Filter.Id(item.filterentwicklungatlas!)!]:[]),
        ])
        speciesMap[speciesID] = species
    }

    Species.speciesMap = speciesMap
    return speciesMap.values.sorted { $0.name <= $1.name }
}


