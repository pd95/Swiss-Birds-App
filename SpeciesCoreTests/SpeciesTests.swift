//
//  SpeciesTests.swift
//  SpeciesCoreTests
//
//  Created by Philipp on 19.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import XCTest
import SpeciesCore

class SpeciesTests: XCTestCase {

    func test_speciesAreDifferentIfIDIsDifferent() {
        let species1 = Species(id: 1, name: "Species 1", synonyms: "Synonym", alias: "Alias", voiceData: true)
        let species2 = Species(id: 2, name: "Species 1", synonyms: "Synonym", alias: "Alias", voiceData: true)

        XCTAssertNotEqual(species1, species2)
        XCTAssertNotEqual(species1.hashValue, species2.hashValue)
    }
}
