//
//  SpeciesCoreTests.swift
//  SpeciesCoreTests
//
//  Created by Philipp on 15.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import XCTest
import SpeciesCore

class FilterTests: XCTestCase {

    // MARK: - test FilterType

    func test_FilterType_typesHaveDifferentID() {
        let type1 : FilterType = "Type1"
        let type2 : FilterType = "Type2"

        XCTAssertNotEqual(type1, type2)
        XCTAssertNotEqual(type1.name, type2.name)
        XCTAssertNotEqual(type1.id, type2.id)
        XCTAssertNotEqual(type1.hashValue, type2.hashValue)
    }

    func test_FilterType_sameNamesReturnsSameType() {
        let type1 : FilterType = "Type1"
        let type2 : FilterType = "Type1"

        XCTAssertEqual(type1, type2)
        XCTAssertEqual(type1.name, type2.name)
        XCTAssertEqual(type1.id, type2.id)
        XCTAssertEqual(type1.hashValue, type2.hashValue)
    }

    // MARK: - test Filter

    func test_Filter_differentFilterTypeButSameIDIsNotSame() {
        let filterA = Filter(type: "Type1", id: 0, name: "filter")
        let filterB = Filter(type: "Type2", id: 0, name: "filter")
        XCTAssertNotEqual(filterA, filterB)
        XCTAssertNotEqual(filterA.hashValue, filterB.hashValue)
        XCTAssertNotEqual(filterA.uniqueID, filterB.uniqueID)
    }

    func test_Filter_sameFilterTypeAndSameIDIsSame() {
        let filterA = Filter(type: "Type1", id: 0, name: "filterA")
        let filterB = Filter(type: "Type1", id: 0, name: "filterB")
        XCTAssertEqual(filterA, filterB)
        XCTAssertEqual(filterA.hashValue, filterB.hashValue)
        XCTAssertEqual(filterA.uniqueID, filterB.uniqueID)
        XCTAssertNotEqual(filterA.description, filterB.description)
    }

    // MARK: - test FilterCollection

    func test_FilterCollection_isInitiallyEmpty() {
        let collection = FilterCollection()

        XCTAssertEqual(collection.allTypes, [])
        XCTAssertEqual(collection.filters(for: "Type1"), [])
    }

    func test_FilterCollection_addFilter_storesTypeAndFilter() {
        var collection = FilterCollection()
        let filterA = collection.addFilter(type: "Type1", id: 0, name: "filterA")

        XCTAssertEqual(collection.allTypes, ["Type1"])

        let filters = collection.filters(for: "Type1")
        XCTAssertEqual(filters.count, 1)
        XCTAssertEqual(filters.first, filterA)

        XCTAssertEqual(collection.filter(withID: 0, for: "Type1"), filterA, "ID should find filterA")
        XCTAssertNil(collection.filter(withID: 1, for: "Type1"), "Wrong ID should not find any filter")
        XCTAssertNil(collection.filter(withID: 0, for: "Type2"), "ID should not find any Type2 filter")
    }

    func test_FilterCollection_addFilter_storesMultipleFiltersWithDifferentID() {
        var collection = FilterCollection()
        let filterA = collection.addFilter(type: "Type1", id: 0, name: "filterA")
        let filterB = collection.addFilter(type: "Type1", id: 1, name: "filterB")

        XCTAssertEqual(collection.allTypes, ["Type1"])

        let filters = collection.filters(for: "Type1")
        XCTAssertEqual(filters.count, 2)
        XCTAssertTrue(filters.contains(filterA), "filterA found")
        XCTAssertTrue(filters.contains(filterB), "filterB found")
    }

    func test_FilterCollection_addFilter_distinguishesDifferentTypes() {
        var collection = FilterCollection()
        let filterA = collection.addFilter(type: "Type1", id: 0, name: "filterA")
        let filterB = collection.addFilter(type: "Type2", id: 0, name: "filterA")

        XCTAssertEqual(collection.allTypes, ["Type1", "Type2"])

        let filtersType1 = collection.filters(for: "Type1")
        XCTAssertEqual(filtersType1.count, 1)
        XCTAssertTrue(filtersType1.contains(filterA), "filterA found")
        XCTAssertFalse(filtersType1.contains(filterB), "filterB not found")

        let filtersType2 = collection.filters(for: "Type2")
        XCTAssertEqual(filtersType2.count, 1)
        XCTAssertFalse(filtersType2.contains(filterA), "filterA not found")
        XCTAssertTrue(filtersType2.contains(filterB), "filterB found")
    }

    func test_FilterCollection_addFilterTwiceWithSameIDUpdates() {
        var collection = FilterCollection()
        let filterA = collection.addFilter(type: "Type1", id: 0, name: "filterA")
        let filterB = collection.addFilter(type: "Type1", id: 0, name: "filterB")

        let filters = collection.filters(for: "Type1")
        XCTAssertTrue(filters.contains(filterA), "filterA found")
        XCTAssertTrue(filters.contains(filterB), "filterB found")
    }
}
