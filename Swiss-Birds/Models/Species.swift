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

    var name : String {
        translatedNames[primaryLanguage, default: "name"]
    }
    var alternateName : String {
        translatedAlternateNames[primaryLanguage, default: "alternateName"]
    }

    var translatedNames = [LanguageIdentifier: String]()
    var translatedAlternateNames = [LanguageIdentifier: String]()
    var searchableNames = [LanguageIdentifier: String]()

    mutating func addTranslation(for language: LanguageIdentifier, name: String, alternateName: String) {
        var alternateName = " \(alternateName) "
        if let range = alternateName.range(of: " \(name) ") {
            alternateName = alternateName.replacingCharacters(in: range, with: "")
        }
        translatedNames[language] = name
        translatedAlternateNames[language] = alternateName.trimmingCharacters(in: .whitespaces)
        searchableNames[language] = name.lowercased() + " " + alternateName.lowercased()
    }

    mutating func addTranslation(for language: LanguageIdentifier, vdsListElement: VdsListElement) {
        addTranslation(for: language, name: vdsListElement.artname, alternateName: vdsListElement.synonyme)
    }

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
        let lowercasedWords = text.lowercased().split(separator: " ")
        for (_, lowercaseNames) in searchableNames {
            for word in lowercasedWords {
                if lowercaseNames.contains(word) {
                    return true
                }
            }
        }
        return false
    }

    // Returns a dictionary with all names and alternate names matching the query text
    // duplicating parts of `nameMatches`
    func allNameMatches(_ text: String) -> [LanguageIdentifier: (name: String?, alternateName: String?)] {
        if text.isEmpty {
            return [:]
        }
        let lowercasedWords = text.lowercased().split(separator: " ")
        var matches = [LanguageIdentifier: (name: String?, alternateName: String?)]()
        for (language, name) in translatedNames {
            let alternateName = translatedAlternateNames[language, default: ""]

            let lowercaseName = name.lowercased()
            let lowercaseAlternateName = alternateName.lowercased()

            var nameMatch = false
            var alternateNameMatch = false
            for word in lowercasedWords {
                nameMatch = nameMatch || lowercaseName.contains(word)
                alternateNameMatch = alternateNameMatch || lowercaseAlternateName.contains(word)
            }
            if nameMatch || alternateNameMatch {
                matches[language] = (nameMatch ? name : nil, alternateNameMatch ? alternateName : nil)
            }
        }
        return matches
    }

    func categoryMatches(filters: FilterList) -> Bool {
        if filters.isEmpty {
            return true
        }
        
        var matchesAll = true
        for (type, relevantIds) in filters {
            matchesAll = matchesAll && (!type.isFilterCategory || (filterMap[type] ?? []).reduce(false, { $0 || relevantIds.contains($1)}))
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
    
    static let placeholder = Species(speciesId: -1, name: "Placeholder", alternateName: "", filterMap: FilterList())
}

extension Species {
    init(speciesId: Species.Id, name: String, alternateName: String, filterMap: FilterList) {
        self.speciesId = speciesId
        self.filterMap = filterMap
        addTranslation(for: primaryLanguage, name: name, alternateName: alternateName)
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
                .vogelstimme : [Filter.Id(item.voice ?? "0")!],
        ])
        speciesMap[speciesID] = species
    }

    Species.speciesMap = speciesMap
    return speciesMap.values.sorted { $0.name <= $1.name }
}


