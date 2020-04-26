//
//  Data.swift
//  Swiss-Birds
//
//  Created by Philipp on 01.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation
import UIKit

let availableLanguages = ["de","fr","it","en"]
let language = Bundle.preferredLocalizations(from: availableLanguages).first!


func load<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T {
    let data: Data
    
    do {
        // Try first to fetch file from main bundle
        if let file = Bundle.main.url(forResource: filename, withExtension: nil) {
            data = try Data(contentsOf: file)
        }
        else {
            // Then try to find a localized resource or otherwise a non-localized resource
            guard let asset = NSDataAsset(name: "\(language)/\(filename)") ?? NSDataAsset(name: filename) else {
                fatalError("Couldn't find asset \(filename) in bundle and asset catalog")
            }
            data = asset.data
        }
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}


func loadSpeciesData() -> [Species] {

    // Helper structure to decode JSON
    struct VdsList: Codable {
        let artID, sysNr, artname, alternativName: String
        let alias, filterlebensraum, filtervogelgruppe, filternahrung: String
        let filterhaeufigeart, filterrotelistech: String
        let filterentwicklungatlas: String?

        enum CodingKeys: String, CodingKey {
            case artID = "ArtId"
            case sysNr = "Sys_Nr"
            case artname = "Artname"
            case alternativName = "Alternativ_Name"
            case alias, filterlebensraum, filtervogelgruppe, filternahrung, filterhaeufigeart, filterrotelistech, filterentwicklungatlas
        }
    }

    // Load and decode file
    let vdsList : [VdsList] = load("vds-list.json")

    
    var speciesList = [Species]()

    vdsList.forEach { (item) in
        let species = Species(
            speciesId: Species.Id(item.artID)!,
            name: item.artname,
            alternateName: item.alternativName,
            filterMap: [
                .lebensraum : item.filterlebensraum.split(separator: ",").map({ (s) -> Filter.Id in
                    return Filter.Id(String(s.trimmingCharacters(in: .whitespaces)))!
                }),
                .vogelgruppe : [Filter.Id(item.filtervogelgruppe)!],
                .nahrung : item.filternahrung.split(separator: ",").map({ (s) -> Filter.Id in
                    return Filter.Id(String(s.trimmingCharacters(in: .whitespaces)))!
                }),
                .haeufigeart : [Filter.Id(item.filterhaeufigeart)!],
                .roteListe : (item.filterrotelistech.count > 0 ? [Filter.Id(item.filterrotelistech)!]:[]),
                .entwicklungatlas : (item.filterentwicklungatlas?.count ?? 0 > 0 ? [Filter.Id(item.filterentwicklungatlas!)!]:[]),
        ])
        speciesList.append(species)
    }
    
    return speciesList.sorted { $0.name <= $1.name }
}


func loadFilterData() -> [FilterType:[Filter]] {
    // Helper structure to decode JSON
    struct VdsFilternames: Codable {
        let type, filterID, filterName: String
    }

    // Load and decode file
    let vdsFilternames : [VdsFilternames] = load("vds-filternames.json")

    
    var filterMap = [FilterType:[Filter]]()

    // Initialize "häufige Art" which is missing in the vds-filternames.json data
    filterMap[.haeufigeart] = [
        Filter(filterId: 0, name: "Selten", type: .haeufigeart),
        Filter(filterId: 1, name: "Häufig", type: .haeufigeart)
    ]

    vdsFilternames.forEach { (vdsFilter) in
        let filterType = FilterType(rawValue: vdsFilter.type)!
        let filter = Filter(filterId: Filter.Id(vdsFilter.filterID) ?? -999, name: vdsFilter.filterName, type: filterType)

        if filterMap[filterType] == nil {
            filterMap[filterType] = [filter]
        }
        else {
            filterMap[filterType]?.append(filter)
        }
    }

    // Sort all filters according to the current language
    FilterType.allCases.forEach { (type) in
        if type.shouldSortForDisplay {
            filterMap[type]?.sort(by: { (lhs, rhs) -> Bool in
                NSLocalizedString(lhs.name, comment: "") < NSLocalizedString(rhs.name, comment: "")
            })
        }
    }

    return filterMap
}
