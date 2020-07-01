//
//  VdsAPI.swift
//  Swiss-Birds
//
//  Created by Philipp on 14.06.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation
import os.log
import Combine

enum VdsAPI {

    enum APIError: Error {
        case networkError(String)
        case httpError(Int, String)
        case resourceLoadError(String)
        case decodingError(String)
        case invalidResponse
    }

    typealias BirdOfTheDayData = (url: URL, speciesID: Int)

    static var urlSession: URLSession = {
        let cacheLocation: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("Downloaded-Data")
        let cacheSize = 200 * 1024 * 1024

        var config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: cacheSize, diskCapacity: cacheSize, directory: cacheLocation)

        return URLSession(configuration: config)
    }()

    static let decoder: JSONDecoder = JSONDecoder()
    static let base = URL(string: "https://www.vogelwarte.ch/")!

    static let jsonDataPath = "elements/snippets/vds/static/assets/data"
    static let imageAssetPath = "assets/images/voegel/vds"
    static let voiceAssetPath = "assets/media/voices"

    private static func fetchData(_ request: URLRequest) -> AnyPublisher<Data, Error> {
        return urlSession
            .dataTaskPublisher(for: request)
            .tryMap { result -> Data in
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    os_log("Invalid HTTP response: %{Public}@", result.response)
                    throw APIError.networkError("Invalid HTTP response")
                }

                let statusCode = httpResponse.statusCode
                guard 200 ..< 300 ~= statusCode else {
                    let localizedMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                    os_log("Unexpected HTTP response code: %d %{Public}@\n%{Public}@", statusCode, localizedMessage, httpResponse.url!.path)
                    throw APIError.httpError(statusCode, "HTTP \(statusCode): \(localizedMessage)")
                }
                return result.data
            }
            .eraseToAnyPublisher()
    }

    private static func fetchJSON<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        return fetchData(request)
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }

    static func getBirds() -> AnyPublisher<[VdsListElement], Error> {
        return fetchJSON(URLRequest(url: base.appendingPathComponent("\(jsonDataPath)/vds-list-\(language).json")))
    }

    static func getFilters() -> AnyPublisher<[VdsFilter], Error> {
        return fetchJSON(URLRequest(url: base.appendingPathComponent("\(jsonDataPath)/vds-filternames-\(language).json")))
    }

    static func getLabels() -> AnyPublisher<[VdsLabel], Error> {
        return fetchJSON(URLRequest(url: base.appendingPathComponent("\(jsonDataPath)/vds-labels-\(language).json")))
    }

    static func getSpecie(for id: Int) -> AnyPublisher<VdsSpecieDetail, Error> {
        return fetchJSON(URLRequest(url: base.appendingPathComponent("\(jsonDataPath)/species/\(id)-\(language).json")))
            .tryMap { (d: [VdsSpecieDetail]) -> VdsSpecieDetail in d.first!}
            .eraseToAnyPublisher()
    }

    static func getSpecieImage(for id: Int, number: Int, size: Int = 700) -> AnyPublisher<Data, Error> {
        return fetchData(URLRequest(url: base.appendingPathComponent("\(imageAssetPath)/artbilder/\(size)px/\(String(format: "%04d", id))_\(number).jpg")))
    }

    static func getSpecieHeadshot(for id: Int, scale: Int = 2) -> AnyPublisher<Data, Error> {
        return fetchData(URLRequest(url: base.appendingPathComponent("\(imageAssetPath)/headshots/80x80/\(id)@\(scale)x.jpg")))
    }

    static func getVoice(for id: Int) -> AnyPublisher<Data, Error> {
        return fetchData(URLRequest(url: base.appendingPathComponent("\(voiceAssetPath)/\(id).mp3")))
    }

    static func getBirdOfTheDaySpeciesIDandURL() -> AnyPublisher<BirdOfTheDayData, Error> {
        return fetchData(URLRequest(url: base))
            .tryMap { (data) -> (url: URL, artID: Int) in
                let html = String(data: data, encoding: .isoLatin1)!
                let matches = html.matches(regex: "assets/images/headImages/vdt/([0-9]+).jpg")
                if matches.count == 2, let id = Int(matches[1]) {
                    let url = base.appendingPathComponent(matches[0])
                    return (url, id)
                }
                throw APIError.invalidResponse
            }
            .eraseToAnyPublisher()
    }

    static func getBirdOfTheDay(for id: Int) -> AnyPublisher<Data, Error> {
        return fetchData(URLRequest(url: base.appendingPathComponent("assets/images/headImages/vdt/\(String(format: "%04d", id)).jpg")))
    }
}
