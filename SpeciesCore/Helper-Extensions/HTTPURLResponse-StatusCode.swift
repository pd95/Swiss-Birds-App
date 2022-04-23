//
//  HTTPURLResponse-StatusCode.swift
//  SpeciesCore
//
//  Created by Philipp on 16.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    private static var SUCCESSFUL_2xx = 200..<300
    private static var REDIRECTION_4xx = 300..<400
    private static var CLIENT_ERR_4xx = 400..<500
    private static var SERVER_ERR_5xx = 500..<600

    public enum Errors: Error {
        case clientError(Int)
        case serverError(Int)
        case unexpectedStatusCode(Int)
    }

    public func checkStatusCode() throws {
        switch statusCode {
        case HTTPURLResponse.SUCCESSFUL_2xx:
            break
        case HTTPURLResponse.CLIENT_ERR_4xx:
            throw Errors.clientError(statusCode)
        case HTTPURLResponse.SERVER_ERR_5xx:
            throw Errors.serverError(statusCode)
        default:
            throw Errors.unexpectedStatusCode(statusCode)
        }
    }
}
