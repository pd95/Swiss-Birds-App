//
//  Data.swift
//  Swiss-Birds
//
//  Created by Philipp on 01.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation
import UIKit


func load<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T {
    let data: Data
    
    do {
        // Try first to fetch file from main bundle
        if let file = Bundle.main.url(forResource: filename, withExtension: nil) {
            data = try Data(contentsOf: file)
        }
        else {
            // Then try to find a localized resource or otherwise a non-localized resource
            guard let asset = NSDataAsset(name: "\(primaryLanguage)/\(filename)") ?? NSDataAsset(name: filename) else {
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


func loadFilterData(vdsFilternames : [VdsFilter]) -> [FilterType:[Filter]] {

    var filterMap = [FilterType:[Filter]]()

    // Initialize "häufige Art" which is missing in the vds-filternames.json data
    filterMap[.haeufigeart] = [
        Filter(filterId: 0, name: "Selten", type: .haeufigeart),
        Filter(filterId: 1, name: "Häufig", type: .haeufigeart)
    ]

    filterMap[.vogelstimme] = [
        Filter(filterId: 0, name: "Fehlt", type: .vogelstimme),
        Filter(filterId: 1, name: "Vorhanden", type: .vogelstimme)
    ]

    vdsFilternames.forEach { (vdsFilter) in
        let filterType = FilterType(rawValue: vdsFilter.type)!
        let filter = Filter(filterId: Filter.Id(vdsFilter.filterID) ?? -999, name: vdsFilter.filterName, type: filterType)

        filterMap[filterType, default: []].append(filter)
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
