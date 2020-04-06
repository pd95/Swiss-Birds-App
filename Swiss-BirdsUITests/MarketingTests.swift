//
//  MarketingTests.swift
//  Swiss-BirdsUITests
//
//  Created by Philipp on 19.12.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import XCTest

class MarketingTests: XCTestCase {

    private var app: XCUIApplication!
    private var language = "de"
    
    func takeScreenShot(_ element: XCUIElement, name: String = "Screenshot") {
        let screenshot = element.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launchArguments.append("enable-testing")
        app.launch()

        // Rotate iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            // Change orientation twice to ensure double column navigation bar works
            XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeLeft;
            XCUIDevice.shared.orientation = UIDeviceOrientation.portrait;
        }

        // Check if a specifc language has been passed on for testing
        if let langArgIndex = CommandLine.arguments.firstIndex(of: "-AppleLanguages") {
            let languageArgument = CommandLine.arguments[langArgIndex+1]
            print("language argument=\(languageArgument)")
            if languageArgument == "(fr)" {
                language = "fr"
            }
            else if languageArgument == "(it)" {
                language = "it"
            }
            else if languageArgument == "(en)" {
                language = "en"
            }
        }
        else {
            language = Locale.current.languageCode ?? "de"
            print("language from locale=\(language)")
        }
        
        assert(["de", "fr", "it", "en"].contains(language), "Language \(language) is not supported for test execution")

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMainNavigation() {
        XCTContext.runActivity(named: "Identify main view") { (_) in
            let nav = app.navigationBars.containing(.button, identifier: "filterButton").element
            XCTAssert(nav.waitForExistence(timeout: 2), "The main navigation bar exists")
            takeScreenShot(app, name: "01_Main")
        }
        
        // Search
        let selectIndex = language == "fr" ? 2 : 0
        XCTContext.runActivity(named: "Search for a bird") { (_) in
            let searchTerms = ["de": "Amsel", "fr": "Merle", "it": "Merlo", "en": "Blackbird"]
            let search = searchTerms[language]!

            let searchText = app.searchFields.textFields["searchText"].firstMatch
            searchText.tap()
            searchText.typeText(search)
            takeScreenShot(app, name: "02_Search")
            searchText.typeText("\n")
        }

        // Show Detail
        XCTContext.runActivity(named: "Show detail view and scroll down") { (_) in
            app.tables.buttons.element(boundBy: selectIndex).tap()
            takeScreenShot(app, name: "03_Detail_Top")

            let scrollViewsQuery = app.scrollViews
            scrollViewsQuery.otherElements.containing(.staticText, identifier:"alternateName").element.swipeUp()
            takeScreenShot(app, name: "04_Detail_Middle")
        }

        // Tap "Back"
        XCTContext.runActivity(named: "Clear search and enter filter criteria") { (_) in
            if UIDevice.current.userInterfaceIdiom != .pad {
                app.navigationBars.buttons.firstMatch.tap()
            }

            // Clear search
            let clearButton = app.searchFields.buttons.firstMatch
            _ = clearButton.waitForExistence(timeout: 2)
            clearButton.tap()

            let nav = app.navigationBars.containing(.button, identifier: "filterButton").element
            XCTAssert(nav.exists, "The main view navigation bar does not exist")

            // Enter filter criteria
            nav.buttons["filterButton"].tap()
            app.tables.buttons["onlyCommon"].tap()
            takeScreenShot(app, name: "05_Filtercriteria")
        }

        // Tap "Back"
        XCTContext.runActivity(named: "Go back to main view") { (_) in
            if UIDevice.current.userInterfaceIdiom != .pad {
                app.navigationBars.buttons.firstMatch.tap()
            }
        }

    }

}
