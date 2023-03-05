//
//  RemoteDataClientTests.swift
//  SpeciesCoreTests
//
//  Created by Philipp on 15.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import XCTest
import SpeciesCore

class RemoteDataClientTests: XCTestCase {

    override func tearDown() {
        super.tearDown()

        URLProtocolStub.removeStub()
    }

    func test_dataFromURL_performsGETRequestWithURL() async throws {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        let client = makeSUT()

        let _ = try await client.data(from: url)
        wait(for: [exp], timeout: 1.0)
    }

    func test_dataFromURL_cancelWorks() async {
        let receivedError = await resultErrorFor(taskHandler: { $0.cancel() }) as NSError?

        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }

    func test_dataFromURL_throwsOnRequestError() async throws {
        let requestError = anyNSError()
        let receivedError = await resultErrorFor(
            (data: nil, response: nil, error: requestError)
        )
        XCTAssertNotNil(receivedError)
    }


    func test_dataFromURL_throwsOnNonHTTPResponse() async throws {
        let receivedError = await resultErrorFor(
            (data: nil,
             response: nonHTTPURLResponse(),
             error: nil)
        )
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError as? RemoteDataClient.Errors, .invalidResponse)
    }

    func test_dataFromURL_throwsOnInvalidStatusCode() async throws {
        let invalidStatusCodes = [0, 100, 199, 300, 399, 400, 499, 500, 599, 600, 999]

        for invalidStatusCode in invalidStatusCodes {
            let receivedError = await resultErrorFor(
                (data: nil,
                 response: HTTPURLResponse(statusCode: invalidStatusCode),
                 error: nil)
            )
            XCTAssertNotNil(
                receivedError,
                "Status code \(invalidStatusCode) should throw an error"
            )
        }
    }

    func test_dataFromURL_failsOnAllInvalidRepresentationCases() async {
        // let _ = await resultErrorFor((data: nil, response: nil, error: nil))             // not possible!
        // let _ =   await resultErrorFor((data: anyData(), response: nil, error: nil))     // not possible!
        let _ = await resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: nil))
        let _ = await resultErrorFor((data: anyData(), response: nil, error: anyNSError()))
        let _ = await resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        let _ = await resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        let _ = await resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        let _ = await resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        let _ = await resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }


    // MARK: - Helper

    private func resultErrorFor(_ stubValues: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (Task<(Data, URLResponse), Error>) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) async -> Error? {

        let result = await resultFor(stubValues, taskHandler: taskHandler, file: file, line: line)

        switch result {
        case .failure(let error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }

    private func resultValuesFor(_ stubValues: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (Task<(Data, URLResponse), Error>) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) async -> (Data, URLResponse)? {

        let result = await resultFor(stubValues, taskHandler: taskHandler, file: file, line: line)

        switch result {
        case .success(let values):
            return values
        default:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)
            return nil
        }
    }

    private func resultFor(_ stubValues: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (Task<(Data, URLResponse), Error>) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) async -> Result<(Data, URLResponse), Error> {
        stubValues.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }

        let sut = makeSUT(file: file, line: line)

        let task: Task<(Data, URLResponse), Error> = Task(operation: { try await sut.data(from: anyURL()) })
        taskHandler(task)

        return await task.result
    }

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> RemoteDataClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let client = RemoteDataClient(urlSession: session)

        return client
    }

    private func makeItem(typeName: String, id: Int, name: String) -> (Filter, json: [String: Any]) {

        let item = Filter(type: FilterType(typeName), id: id, name: name)

        let json = [
            "type": typeName,
            "filter_id": String(id),
            "filter_name": name
        ].compactMapValues { $0 }

        return (item, json)
    }

    private func makeItemsJSON(_ json: [[String: Any]]) -> Data {
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
}
