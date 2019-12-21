//
//  schweizer_voegelUITests.swift
//  schweizer-voegelUITests
//
//  Created by Philipp on 30.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import XCTest

class schweizer_voegelUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launchArguments.append("enable-testing")
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        super.tearDown()

        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testMainNavigation() {
        let nav = app.navigationBars.containing(.button, identifier: "filterButton").element
        XCTAssert(nav.exists, "The main view navigation bar does not exist")
    }

    func testFilterNavigation() {
        var nav = app.navigationBars.containing(.button, identifier: "filterButton").element
        XCTAssert(nav.exists, "The main view navigation bar does not exist")
        nav.buttons["filterButton"].tap()

        app.tables.buttons["noFiltering"].tap()

        nav = app.navigationBars.firstMatch
        XCTAssert(nav.identifier.contains("(425 "), "No filtering should result in 425 species")

        app.tables.buttons["onlyCommon"].tap()
        XCTAssert(nav.identifier.contains("(94 "), "Common filter should reduce to 94 species")
    }

    func testDetailNavigation() {
        let nav = app.navigationBars.containing(.button, identifier: "filterButton").element
        XCTAssert(nav.exists, "The main view navigation bar does not exist")

        app.tables.buttons["birdRow_1200"].tap()

        let scrollViewsQuery = app.scrollViews
        scrollViewsQuery.otherElements.containing(.staticText, identifier:"alternateName").element.swipeUp()
        scrollViewsQuery.otherElements.containing(.staticText, identifier:"Laenge_cm").element.swipeUp()
    }
    
    func testTestFullNavigation() {
        let nav = app.navigationBars.containing(.button, identifier: "filterButton").element
        XCTAssert(nav.exists, "The main view navigation bar does not exist")
        
        // Search
        var search = "Amsel"
        var selectIndex = 0
        if let langArgIndex = CommandLine.arguments.firstIndex(of: "-AppleLanguages") {
            let language = CommandLine.arguments[langArgIndex+1]
            print("language=\(language)")
            if language == "(fr)" {
                search = "Merle"
                selectIndex = 2
            }
            else if language == "(it)" {
                search = "Merlo"
            }
            else if language == "(en)" {
                search = "Blackbird"
            }
        }

        let searchText = app.searchFields.textFields["searchText"].firstMatch
        searchText.tap()
        searchText.typeText(search)

        // Show Detail
        app.tables.buttons.element(boundBy: selectIndex).tap()
        
        let scrollViewsQuery = app.scrollViews
        scrollViewsQuery.otherElements.containing(.staticText, identifier:"alternateName").element.swipeUp()

        // Tap "Back"
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssert(nav.exists, "The main view navigation bar does not exist")

        // Enter filter criteria
        nav.buttons["filterButton"].tap()

        // Tap "Back"
        app.navigationBars.buttons.firstMatch.tap()
    }

    
    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
