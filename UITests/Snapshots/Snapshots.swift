//
//  Snapshots.swift
//  Snapshots
//
//  Created by Philipp on 17.10.21.
//  Copyright © 2021 Philipp. All rights reserved.
//

import XCTest

class Snapshots: XCTestCase {

    private var app: XCUIApplication!
    private var language = "de"
    private let wait4existenceTimeout: TimeInterval = 4

    private func takeScreenShot(_ name: String = "Screenshot") {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        snapshot(name)
    }

    override func setUp() {

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments.append("enable-testing")
        app.launch()

        // Rotate iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            // Change orientation twice to ensure double column navigation bar works
            XCUIDevice.shared.orientation = .portrait
            XCUIDevice.shared.orientation = .landscapeLeft
        }

        print("app.launchArguments", app.launchArguments)
        // Check if a specific language has been passed on for testing
        if let langArgIndex = app.launchArguments.firstIndex(of: "-AppleLanguages") {
            let languageArgument = app.launchArguments[langArgIndex+1]
            print("language argument=\(languageArgument)")
            if languageArgument == "(fr)" {
                language = "fr"
            } else if languageArgument == "(it)" {
                language = "it"
            } else if languageArgument == "(en)" {
                language = "en"
            }
        } else {
            language = Locale.current.languageCode ?? "de"
            print("language from locale=\(language)")
        }

        assert(["de", "fr", "it", "en"].contains(language), "Language \(language) is not supported for test execution")

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    func testSnapshot() throws {
        if app == nil {
            setUp()
        }

        XCTContext.runActivity(named: "Bird of the day is shown") { (_) in
            let dismissButton = app.buttons["dismissBirdOfTheDay"].firstMatch
            XCTAssert(dismissButton.waitForExistence(timeout: wait4existenceTimeout), "The bird of the day dismiss button exists")
            takeScreenShot("00_BirdOfTheDay")
            dismissButton.tap()
        }

        XCTContext.runActivity(named: "Identify main view") { (_) in
            let nav = app.navigationBars.containing(.button, identifier: "filterButton").element
            XCTAssert(nav.waitForExistence(timeout: wait4existenceTimeout), "The main navigation bar exists")
            takeScreenShot("01_Main")
        }

        // Search
        XCTContext.runActivity(named: "Search for a bird") { (_) in
            let searchTerms = ["de": "Amsel", "fr": "Merle", "it": "Merlo", "en": "Black"]
            let search = searchTerms[language]!

            let searchText = app.searchFields.allElementsBoundByIndex.last!
            searchText.tap()
            typeText(search)
            takeScreenShot("02_Search")
            searchText.typeText("\n")
        }

        // Show Detail
        XCTContext.runActivity(named: "Show detail view and scroll down") { (_) in
            let birdButton = app.buttons["birdRow_4240"]
            _ = birdButton.waitForExistence(timeout: wait4existenceTimeout)
            birdButton.tap()

            let birdImage = app.otherElements["bird_image_1"]
            _ = birdImage.waitForExistence(timeout: wait4existenceTimeout)
            takeScreenShot("03_Detail_Top")

            let scrollViewsQuery = app.scrollViews
            scrollViewsQuery.otherElements["bird_image_2"].swipeUp()
            while scrollViewsQuery.staticTexts["text_Nahrung"].isHittable == false {
                app.swipeUp()
            }
            app.swipeUp()
            takeScreenShot("04_Detail_Middle")
        }

        XCTContext.runActivity(named: "Cancel search and enter filter criteria") { (_) in
            // Tap "Back"
            app.navigationBars.buttons.firstMatch.tap()

            // Make sure searchField is visible and selected again
            let searchField = app.searchFields.element
            searchField.tap()

            // Cancel search
            let cancelButton = app.otherElements["searchBar"].buttons["cancelButton"]
            _ = cancelButton.waitForExistence(timeout: wait4existenceTimeout)
            cancelButton.tap()

            let nav = app.navigationBars.containing(.button, identifier: "filterButton").element
            XCTAssert(nav.exists, "The main view navigation bar does not exist")

            // Enter filter criteria
            let filterButton = nav.buttons["filterButton"]
            _ = filterButton.waitForExistence(timeout: wait4existenceTimeout)
            XCTAssert(filterButton.exists, "filter button exists")
            filterButton.tap()

            let commonBirdsButton = app.buttons["onlyCommon"]
            _ = commonBirdsButton.waitForExistence(timeout: wait4existenceTimeout)
            XCTAssert(commonBirdsButton.exists, "'only common birds' button exists")
            commonBirdsButton.tap()

            takeScreenShot("05_Filtercriteria")
        }

        XCTContext.runActivity(named: "Go back to main view") { (_) in
            // Tap "Back"
            app.navigationBars.buttons.firstMatch.tap()

            // Navigate to Sort Options screen
            let sortButton = app.buttons["sortButton"]
            _ = sortButton.waitForExistence(timeout: wait4existenceTimeout)
            sortButton.tap()

            // Choose "Bird groups"
            let birdGroupsButton = app.buttons["filtervogelgruppe"]
            _ = birdGroupsButton.waitForExistence(timeout: wait4existenceTimeout)
            birdGroupsButton.tap()

            takeScreenShot("06_Sortoptions")

            // Tap "Back"
            app.navigationBars.buttons.firstMatch.tap()

            takeScreenShot("07_GroupedBirdList")
        }

    }
}
