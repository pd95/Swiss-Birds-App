//
//  SectionGroup.swift
//  SwissBirds
//
//  Created by Philipp on 01.11.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

struct SectionGroup: Hashable, Identifiable, Comparable {
    let id: String
    let name: String

    static func < (lhs: SectionGroup, rhs: SectionGroup) -> Bool {
        lhs.name < rhs.name
    }
}
