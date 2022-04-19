//
//  FilterTests.swift
//  SpeciesCoreTests
//
//  Created by Philipp on 15.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import XCTest
import SpeciesCore

class FilterTests: XCTestCase {

    func test_FilterType_typesHaveDifferentID() {
        let type1 = FilterType.filterType(for: "Type1")
        let type2 = FilterType.filterType(for: "Type2")

        XCTAssertNotEqual(type1, type2)
        XCTAssertNotEqual(type1.hashValue, type2.hashValue)
    }

    func test_FilterType_sameNamesReturnsSameType() {
        let type1 = FilterType.filterType(for: "Type1")
        let type2 = FilterType.filterType(for: "Type1")

        XCTAssertEqual(type1, type2)
        XCTAssertEqual(type1.type, type2.type)
        XCTAssertEqual(type1.id, type2.id)
        XCTAssertEqual(type1.hashValue, type2.hashValue)
        XCTAssertEqual(type1.description, type2.description)
    }

    func test_Filter_differentFilterTypeButSameIDIsNotSame() {
        let type1 = FilterType.filterType(for: "Type1")
        let type2 = FilterType.filterType(for: "Type2")

        let filterA = Filter(type: type1, id: 0, name: "filter")
        let filterB = Filter(type: type2, id: 0, name: "filter")
        XCTAssertNotEqual(filterA, filterB)
        XCTAssertNotEqual(filterA.hashValue, filterB.hashValue)
    }

    func test_Filter_sameFilterTypeAndSameIDIsSame() {
        let filterA = Filter(type: FilterType.filterType(for: "Type1"), id: 0, name: "filterA")
        let filterB = Filter(type: FilterType.filterType(for: "Type1"), id: 0, name: "filterB")
        XCTAssertEqual(filterA, filterB)
        XCTAssertEqual(filterA.hashValue, filterB.hashValue)
        XCTAssertNotEqual(filterA.description, filterB.description)
    }
}
