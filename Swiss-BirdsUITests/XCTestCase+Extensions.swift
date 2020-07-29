//
//  XCTestCase+Extensions.swift
//  Swiss-BirdsUITests
//
//  Created by Philipp on 29.07.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import XCTest

extension XCTestCase {

    func typeText(_ text: String) {
        let app = XCUIApplication()
        text.forEach {
            app.keys[String($0)].tap()
        }
    }
}
