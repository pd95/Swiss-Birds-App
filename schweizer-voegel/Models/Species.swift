//
//  Arten.swift
//  schweizer-voegel
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

struct Species: Decodable, Identifiable, Hashable {
    let id : Int
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

    func breadcrumbPictureURL() -> URL {
        return URL(string: "https://www.vogelwarte.ch/assets/images/voegel/vds/headshots/80x80/\(id)@1x.jpg")!
    }

    func bigPictureURL() -> URL {
        return URL(string: "https://www.vogelwarte.ch/assets/images/voegel/vds/artbilder/700px/\(id)_0.jpg")!
    }
    
    func matchesSearch(for text: String) -> Bool {
        if text.count == 0 {
            return true
        }
        return name.lowercased().contains(text.lowercased())
    }
}
