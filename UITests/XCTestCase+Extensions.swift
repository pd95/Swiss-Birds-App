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
        let keyboard = app.keyboards.firstMatch
        XCTAssert(keyboard.waitForExistence(timeout: 2), "Keyboard must be visible: Enable software keyboard!")
        if keyboard.keys["A"].isHittable == false {
            let continueButton = app.buttons["Continue"]
            continueButton.tap()
        }
        text.forEach {
            keyboard.keys[String($0)].tap()
        }
    }
}
