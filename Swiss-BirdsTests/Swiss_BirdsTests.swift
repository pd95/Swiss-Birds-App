//
//  Swiss_BirdsTests.swift
//  Swiss_BirdsTests
//
//  Created by Philipp on 30.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import XCTest
import Combine
@testable import Swiss_Birds

class Swiss_BirdsTests: XCTestCase {

    func test_AppState_runsInitialLoad() {
        let appState = AppState.shared
        let exp = expectation(description: "Initial load should finish")

        XCTAssertTrue(appState.initialLoadRunning, "Initial load should be running after creation.")
        var cancellable: AnyCancellable?
        cancellable = appState.objectWillChange
            .sink { _ in
                if appState.initialLoadRunning == false {
                    exp.fulfill()
                    cancellable?.cancel()
                }
            }

        wait(for: [exp], timeout: 10.0)  // We do not know how long it will take! :-(
    }
}
