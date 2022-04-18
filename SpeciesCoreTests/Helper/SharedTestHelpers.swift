//
//  SharedTestHelpers.swift
//  SpeciesCoreTests
//
//  Created by Philipp on 18.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation

func anyURL() -> URL {
    URL(string: "http://example.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
