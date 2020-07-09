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
    private let wait4existenceTimeout: TimeInterval = 4

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
        app.launchArguments.append("no-settings")
        app.launch()

        // Rotate iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            // Change orientation twice to ensure double column navigation bar works
            XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeLeft;
            XCUIDevice.shared.orientation = UIDeviceOrientation.portrait;
        }

        // Check if a specific language has been passed on for testing
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
        takeScreenShot(app, name: "00_Startup")

        XCTContext.runActivity(named: "Dismiss bird of the day") { (_) in
            let dismissButton = app.buttons["dismissBirdOfTheDay"].firstMatch
            XCTAssert(dismissButton.waitForExistence(timeout: wait4existenceTimeout), "The bird of the day dismiss button exists")
            dismissButton.tap()
        }

        XCTContext.runActivity(named: "Identify main view") { (_) in
            let nav = app.navigationBars.containing(.button, identifier: "filterButton").element
            XCTAssert(nav.waitForExistence(timeout: wait4existenceTimeout), "The main navigation bar exists")
            takeScreenShot(app, name: "01_Main")
        }
        
        // Search
        let selectIndex = language == "fr" ? 2 : 0
        XCTContext.runActivity(named: "Search for a bird") { (_) in
            let searchTerms = ["de": "Amsel", "fr": "Merle", "it": "Merlo", "en": "Blackbird"]
            let search = searchTerms[language]!

            let searchText = app.searchFields["searchText"].firstMatch
            searchText.tap()
            searchText.typeText(search)
            takeScreenShot(app, name: "02_Search")
            searchText.typeText("\n")
        }

        // Show Detail
        XCTContext.runActivity(named: "Show detail view and scroll down") { (_) in
            app.tables.buttons.element(boundBy: selectIndex).tap()
            takeScreenShot(app, name: "03_Detail_Top")

            let voiceButton = app.buttons["playVoiceButton"]
            voiceButton.tap()
            sleep(5)
            voiceButton.tap()

            let scrollViewsQuery = app.scrollViews
            scrollViewsQuery.otherElements.containing(.staticText, identifier:"description").element.swipeUp()
            takeScreenShot(app, name: "04_Detail_Middle")
        }

        XCTContext.runActivity(named: "Cancel search and enter filter criteria") { (_) in
            // Tap "Back"
            if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.navigationBars.buttons.firstMatch.tap()
            }

            // Cancel search
            let cancelButton = app.otherElements["searchBar"].buttons["cancelButton"]
            _ = cancelButton.waitForExistence(timeout: wait4existenceTimeout)
            cancelButton.tap()

            let nav = app.navigationBars.containing(.button, identifier: "filterButton").element
            XCTAssert(nav.exists, "The main view navigation bar does not exist")

            // Enter filter criteria
            let filterButton = nav.buttons["filterButton"]
            XCTAssert(filterButton.exists, "filter button exists")
            let commonBirdsButton = app.tables.buttons["onlyCommon"]
            var count = 0
            while !commonBirdsButton.exists && count < 5 {
                filterButton.tap()
                count += 1
            }
            XCTAssert(commonBirdsButton.exists, "'only common birds' button exists")
            commonBirdsButton.tap()
            takeScreenShot(app, name: "05_Filtercriteria")
        }

        XCTContext.runActivity(named: "Go back to main view") { (_) in
            // Tap "Back"
            if app.windows.firstMatch.horizontalSizeClass == .compact {
                app.navigationBars.buttons.firstMatch.tap()
            }
        }

    }

}
