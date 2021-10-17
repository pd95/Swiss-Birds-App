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
        config.timeoutIntervalForRequest = 30

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
            .retry(1)
            .tryMap { result -> Data in
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    os_log("Invalid HTTP response: %{Public}@", result.response)
                    throw APIError.networkError("Invalid HTTP response")
                }

                let statusCode = httpResponse.statusCode
                guard 200 ..< 300 ~= statusCode else {
                    let localizedMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                    os_log("HTTP response: %d '%{Public}@' for %{Public}@", statusCode, localizedMessage, httpResponse.url?.path ?? "n/a")
                    throw APIError.httpError(statusCode, "HTTP \(statusCode): \(localizedMessage)")
                }
                return result.data
            }
            .eraseToAnyPublisher()
    }

    private static func fetchJSON<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        return fetchData(request)
            .decode(type: T.self, decoder: decoder)
            .handleEvents(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    os_log("Error: '%{Public}@' for %{Public}@", error.localizedDescription, request.url?.path ?? "n/a")
                    os_log("%{Public}@", error as NSError)
                }
            })
            .eraseToAnyPublisher()
    }

    static func getBirds(language: LanguageIdentifier = primaryLanguage) -> AnyPublisher<[VdsListElement], Error> {
        return fetchJSON(URLRequest(url: base.appendingPathComponent("\(jsonDataPath)/list_\(language).json")))
    }

    static func getFilters(language: LanguageIdentifier = primaryLanguage) -> AnyPublisher<[VdsFilter], Error> {
        return fetchJSON(URLRequest(url: base.appendingPathComponent("\(jsonDataPath)/filters_\(language).json")))
    }

    static func getLabels(language: LanguageIdentifier = primaryLanguage) -> AnyPublisher<[VdsLabel], Error> {
        return fetchJSON(URLRequest(url: base.appendingPathComponent("\(jsonDataPath)/labels_\(language).json")))
    }

    static func getSpecie(for id: Int, language: LanguageIdentifier = primaryLanguage) -> AnyPublisher<VdsSpecieDetail, Error> {
        return fetchJSON(URLRequest(url: base.appendingPathComponent("\(jsonDataPath)/species/\(id)_\(language).json")))
            .map { (specie: VdsSpecieDetail_new) -> VdsSpecieDetail in
                VdsSpecieDetail(from: specie)
            }
            .eraseToAnyPublisher()
    }

    static func getSpecieImage(for id: Int, number: Int, size: Int = 700) -> AnyPublisher<Data, Error> {
        return fetchData(URLRequest(url: base.appendingPathComponent("\(imageAssetPath)/artbilder/\(size)px/\(String(format: "%04d", id))_\(number).jpg")))
    }

    static func getSpecieHeadshot(for id: Int, scale: Int = 2) -> AnyPublisher<Data, Error> {
        return fetchData(URLRequest(url: base.appendingPathComponent("\(imageAssetPath)/headshots/80x80/\(id)@\(scale)x.jpg")))
    }

    static func getVoice(for id: Int, allowsConstrainedNetworkAccess: Bool = false) -> AnyPublisher<Data, Error> {
        var request = URLRequest(url: base.appendingPathComponent("\(voiceAssetPath)/\(String(format: "%04d", id)).mp3"))
        request.allowsConstrainedNetworkAccess = allowsConstrainedNetworkAccess
        return fetchData(request)
    }

    static func getBirdOfTheDaySpeciesIDandURL() -> AnyPublisher<BirdOfTheDayData, Error> {
        var request = URLRequest(url: base)
        request.cachePolicy = .reloadRevalidatingCacheData
        return fetchData(request)
            .tryMap { (data) -> BirdOfTheDayData in
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
