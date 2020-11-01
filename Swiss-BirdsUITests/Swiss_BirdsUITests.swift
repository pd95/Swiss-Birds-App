//
//  Swiss_BirdsUITests.swift
//  Swiss-BirdsUITests
//
//  Created by Philipp on 30.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import XCTest

class Swiss_BirdsUITests: XCTestCase {

    private var app: XCUIApplication!
    private var language = "de"
    private let wait4existenceTimeout: TimeInterval = 4

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launchArguments.append("enable-testing")
        app.launchArguments.append("no-birdoftheday")
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
        super.tearDown()

        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    

    enum MyUIElements: String {
        case masterNavigationBar, detailNavigationBar
        case filterButton, noFilteringButton = "noFiltering", onlyCommonButton = "onlyCommon", playVoiceButton = "playVoiceButton", showBirdOfTheDayButton = "showBirdOfTheDay", dismissBirdOfTheDayButton = "dismissBirdOfTheDay"
        case sortButton, sortSpeciesName = "speciesName", sortBirdGroup = "filtervogelgruppe", sortCommon = "filterhaeufigeart", sortRedList = "filterrotelistech", sortEvolution = "filterentwicklungatlas"
        case searchTextField = "searchText"
        case searchTextClearButton, searchTextCancelButton
        case birdDetailViewScrollView
        case filterContainerView
        
        var element: XCUIElement {
            switch self {
                case .masterNavigationBar:
                    return XCUIApplication().navigationBars.firstMatch
                case .detailNavigationBar:
                    return XCUIApplication().navigationBars.element(boundBy: XCUIApplication().windows.firstMatch.horizontalSizeClass == .regular ? 1 : 0)
                case .filterButton, .noFilteringButton, .onlyCommonButton, .playVoiceButton, .showBirdOfTheDayButton, .dismissBirdOfTheDayButton,
                     .sortButton, .sortSpeciesName, .sortBirdGroup, .sortCommon, .sortRedList, .sortEvolution:
                    return XCUIApplication().buttons[self.rawValue]
                case .searchTextField:
                    return XCUIApplication().otherElements["searchBar"].searchFields.allElementsBoundByIndex.last!
                case .searchTextClearButton:
                    return XCUIApplication().otherElements["searchBar"].buttons["clearButton"]
                case .searchTextCancelButton:
                    return XCUIApplication().otherElements["searchBar"].buttons["cancelButton"]
                case .birdDetailViewScrollView:
                    return XCUIApplication().scrollViews.containing(.staticText, identifier: "description").element
                case .filterContainerView:
                    return XCUIApplication().tables.containing(.button, identifier: "noFiltering").element
            }
        }
    }

    func testMainNavigation() {
        let nav = MyUIElements.masterNavigationBar.element
        XCTAssert(nav.waitForExistence(timeout: wait4existenceTimeout), "The main navigation bar exists")

        let filterButton = MyUIElements.filterButton.element
        XCTAssert(filterButton.exists, "The main navigation bar exists and contains the filter button")
        
        filterButton.tap()
        
        let detail = MyUIElements.detailNavigationBar.element
        XCTAssert(detail.exists, "The detail navigation bar exists")
    }

    func testFilterNavigation() {
        let filterButton = MyUIElements.filterButton.element
        _ = filterButton.waitForExistence(timeout: wait4existenceTimeout)
        filterButton.tap()

        MyUIElements.noFilteringButton.element.tap()

        let birdDetailNav = MyUIElements.detailNavigationBar.element
        _ = birdDetailNav.waitForExistence(timeout: wait4existenceTimeout)
        XCTAssert(birdDetailNav.identifier.contains("(425 "), "No filtering should result in 425 species")

        MyUIElements.onlyCommonButton.element.tap()
        XCTAssert(birdDetailNav.identifier.contains("(94 "), "Common filter should reduce to 94 species")
    }

    func testDetailNavigation() {
        let nav = MyUIElements.masterNavigationBar.element
        _ = nav.waitForExistence(timeout: wait4existenceTimeout)

        app.tables.buttons.firstMatch.tap()

        let scrollViewsQuery = MyUIElements.birdDetailViewScrollView.element
        scrollViewsQuery.swipeUp()
        scrollViewsQuery.swipeUp()
    }
    
    func testSortOptionsNavigation() {
        // Navigate to Sort Options screen
        let sortButton = MyUIElements.sortButton.element
        _ = sortButton.waitForExistence(timeout: wait4existenceTimeout)
        sortButton.tap()

        // Choose "Bird groups"
        MyUIElements.sortBirdGroup.element.tap()

        // Tap "Back"
        if app.windows.firstMatch.horizontalSizeClass == .compact {
            MyUIElements.masterNavigationBar.element.buttons.firstMatch.tap()
        }

        let expectedSectionIdentifier: String
        let expectedBirdRowIdentifier: String
        switch language {
            case "de":
                expectedBirdRowIdentifier = "birdRow_2895"
                expectedSectionIdentifier = "section_filtervogelgruppe-1"
            case "en", "fr":
                expectedBirdRowIdentifier = "birdRow_4910"
                expectedSectionIdentifier = "section_filtervogelgruppe-7"
            case "it":
                expectedBirdRowIdentifier = "birdRow_440"
                expectedSectionIdentifier = "section_filtervogelgruppe-41"
            default:
                expectedBirdRowIdentifier = "unexpected_language"
                expectedSectionIdentifier = "unexpected_language"
        }

        _ = app.tables.staticTexts.firstMatch.waitForExistence(timeout: wait4existenceTimeout)

        // Verify first visible section is the expected one
        XCTAssertEqual(app.tables.staticTexts.firstMatch.identifier, expectedSectionIdentifier, "Grouped by species group should bring expected section to top of table")

        // Verify first visible bird is the expected one
        XCTAssertEqual(app.tables.buttons.firstMatch.identifier, expectedBirdRowIdentifier, "Grouped by species group should bring expected bird row to first row")


        // Navigate to Sort Options screen
        _ = sortButton.waitForExistence(timeout: wait4existenceTimeout)
        sortButton.tap()

        // Choose "alphabetic"
        MyUIElements.sortSpeciesName.element.tap()

        // Tap "Back"
        if app.windows.firstMatch.horizontalSizeClass == .compact {
            MyUIElements.masterNavigationBar.element.buttons.firstMatch.tap()
        }

        // Verify first visible bird has an "A" in its label
        XCTAssert(app.tables.buttons.firstMatch.label.hasPrefix("A"), "Sorted alphabetically should bring 'A' to first row")
    }

    func testTestFullNavigation() {
        let nav = MyUIElements.masterNavigationBar.element
        _ = nav.waitForExistence(timeout: wait4existenceTimeout)

        // Type something random into search field
        let searchText = MyUIElements.searchTextField.element
        searchText.tap()
        searchText.typeText("Bi")

        // Clear search again
        let clearButton = MyUIElements.searchTextClearButton.element
        _ = clearButton.waitForExistence(timeout: wait4existenceTimeout)
        clearButton.tap()

        // Search a real bird
        let selectIndex = language == "fr" ? 2 : 0
        let searchTerms = ["de": "Amsel", "fr": "Merle", "it": "Merlo", "en": "Blackbird"]
        let search = searchTerms[language]!
        typeText(search)
        searchText.typeText("\n")

        // Show Detail
        app.tables.buttons.element(boundBy: selectIndex).tap()

        var scrollViewsQuery = MyUIElements.birdDetailViewScrollView.element
        _ = scrollViewsQuery.waitForExistence(timeout: wait4existenceTimeout)
        scrollViewsQuery.swipeUp()

        // Tap "Back"
        if app.windows.firstMatch.horizontalSizeClass == .compact {
            MyUIElements.masterNavigationBar.element.buttons.firstMatch.tap()
        }

        // Type Cancel
        let cancelButton = MyUIElements.searchTextCancelButton.element
        _ = cancelButton.waitForExistence(timeout: wait4existenceTimeout)
        cancelButton.tap()

        // Enter filter criteria
        let filterButton = MyUIElements.filterButton.element
        _ = filterButton.waitForExistence(timeout: wait4existenceTimeout)
        filterButton.tap()

        let filterContainer = MyUIElements.filterContainerView.element
        filterContainer.swipeUp()
        filterContainer.swipeUp()
        filterContainer.swipeUp()
        filterContainer.buttons["filtervogelgruppe-11"].tap()
        
        // Tap "Back"
        if app.windows.firstMatch.horizontalSizeClass == .compact {
            MyUIElements.masterNavigationBar.element.buttons.firstMatch.tap()
        }
        
        let merlinBird = app.tables.buttons["birdRow_1450"]
        _ = merlinBird.waitForExistence(timeout: wait4existenceTimeout)
        merlinBird.tap()

        scrollViewsQuery = MyUIElements.birdDetailViewScrollView.element
        scrollViewsQuery.swipeUp()
        scrollViewsQuery.swipeDown()
        
        let voiceButton = MyUIElements.playVoiceButton.element
        voiceButton.tap()
        sleep(5)
        voiceButton.tap()

        // Tap "Back"
        if app.windows.firstMatch.horizontalSizeClass == .compact {
            MyUIElements.masterNavigationBar.element.buttons.firstMatch.tap()
        }
    }

    
    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                app = XCUIApplication()
                app.launchArguments.append("enable-testing")
                app.launchArguments.append("no-birdoftheday")
                app.launch()
            }
        }
    }
}
