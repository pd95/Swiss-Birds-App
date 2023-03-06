//
//  XCTAssertThrowsError-async.swift
//  SpeciesUITests
//
//  Created by Philipp on 06.03.23.
//  Copyright © 2023 Philipp. All rights reserved.
//

import XCTest

func XCTAssertThrowsError<T>(_ expression: @autoclosure () async throws -> T, _ message: @autoclosure () -> String = ""
                               ,file: StaticString = #filePath, line: UInt = #line) async {
    if let _ = try? await expression() {
        XCTFail(message(), file: file, line: line)
        return
    }
}

