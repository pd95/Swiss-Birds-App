//
//  URLProtocolStub.swift
//  SpeciesCoreTests
//
//  Created by Philipp on 18.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation

class URLProtocolStub: URLProtocol {

    // MARK: Stubbing responses

    private struct StubResponse {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        let observer: ((URLRequest) -> Void)?
    }

    private static var _stub: StubResponse?
    private static var stub: StubResponse? {
        get { return queue.sync { _stub } }
        set { queue.sync { _stub = newValue } }
    }

    private static let queue = DispatchQueue(label: "URLProtocolStub.queue")

    static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
        assert(response != nil || error != nil, "Either response or error must be specified")
        stub = StubResponse(data: data, response: response, error: error, observer: nil)
    }

    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        stub = StubResponse(data: Data(), response: HTTPURLResponse(statusCode: 200), error: nil, observer: observer)
    }

    static func removeStub() {
        stub = nil
    }


    // MARK: - Handling the URLProtocol

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let stub = URLProtocolStub.stub else { return }

        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        stub.observer?(request)
    }

    override func stopLoading() {
    }
}
