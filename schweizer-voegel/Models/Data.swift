//
//  Data.swift
//  schweizer-voegel
//
//  Created by Philipp on 01.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

let allSpecies: [Species] = loadSpeciesData()

func load<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
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
    let vdsList : [VdsList] = load("vds-list.json", as: [VdsList].self)

    
    var speciesList = [Species]()

    vdsList.forEach { (item) in
        print(item)
        let species = Species(
            speciesId: Int(item.artID)!,
            name: item.artname,
            alternateName: item.alternativName,
            filterMap: [
                .lebensraum : item.filterlebensraum.split(separator: ",").map({ (s) -> Int in
                    return Int(String(s.trimmingCharacters(in: .whitespaces)))!
                }),
                .vogelgruppe : [Int(item.filtervogelgruppe)!],
                .nahrung : item.filternahrung.split(separator: ",").map({ (s) -> Int in
                    return Int(String(s.trimmingCharacters(in: .whitespaces)))!
                }),
                .haeufigeart : [Int(item.filterhaeufigeart)!],
                .roteListe : (item.filterrotelistech.count > 0 ? [Int(item.filterrotelistech)!]:[]),
                .entwicklungatlas : (item.filterentwicklungatlas?.count ?? 0 > 0 ? [Int(item.filterentwicklungatlas!)!]:[]),
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
    let vdsFilternames : [VdsFilternames] = load("vds-filternames.json", as: [VdsFilternames].self)

    
    var filterMap = [FilterType:[Filter]]()

    // Initialize "häufige Art" which is missing in the vds-filternames.json data
    filterMap[.haeufigeart] = [
        Filter(filterId: 0, name: "Selten", type: .haeufigeart),
        Filter(filterId: 1, name: "Häufig", type: .haeufigeart)
    ]

    vdsFilternames.forEach { (vdsFilter) in
        let filterType = FilterType(rawValue: vdsFilter.type)!
        let filter = Filter(filterId: Int(vdsFilter.filterID) ?? -999, name: vdsFilter.filterName, type: filterType)

        if filterMap[filterType] == nil {
            filterMap[filterType] = [filter]
        }
        else {
            filterMap[filterType]?.append(filter)
        }
    }

    return filterMap
}

let allFilters : [FilterType:[Filter]] = loadFilterData()
