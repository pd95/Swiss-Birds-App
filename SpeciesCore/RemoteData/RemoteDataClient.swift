//
//  RemoteDataClient.swift
//  SpeciesCore
//
//  Created by Philipp on 15.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation

public protocol DataClient {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

public struct RemoteDataClient: DataClient {

    var urlSession: URLSession

    public enum Errors: Error, Equatable {
        case invalidResponse
    }

    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    /// Fetch raw data for a given URL
    public func data(from url: URL) async throws -> (Data, URLResponse) {
        let (data, response) = try await urlSession.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw Errors.invalidResponse
        }
        try httpResponse.checkStatusCode()
        return (data, httpResponse)
    }
}
