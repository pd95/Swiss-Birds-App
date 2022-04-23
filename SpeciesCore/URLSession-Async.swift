//
//  URLSession-Async.swift
//  Swiss-Birds
//
//  Created by Philipp on 23.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation

@available(iOS, introduced: 13.0, deprecated: 15.0, message: "Not needed for iOS 15 and above")
extension URLSession {
    public func data(from url: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        var task: URLSessionDataTask?
        var cancelled = false
        let onCancel = {
            task?.cancel()
            cancelled = true
        }

        return try await withTaskCancellationHandler(handler: { onCancel() }, operation: {
            try await withCheckedThrowingContinuation { continuation in
                task = dataTask(with: url) { data, response, error in
                    let result: Result<(Data, URLResponse), Error>
                    if let response = response {
                        result = .success((data ?? Data(), response))
                    } else {
                        result = .failure(error ?? URLError(.unknown))
                    }
                    continuation.resume(with: result)
                }

                if cancelled {
                    continuation.resume(with: .failure(URLError(.cancelled)))
                } else {
                    task?.resume()
                }
            }
        })
    }
}
