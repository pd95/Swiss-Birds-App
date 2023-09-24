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

    static var cacheLocation: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("Downloaded-Data")
    }

    static var urlSession: URLSession = {
        let cacheSize = 200 * 1024 * 1024

        var config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: cacheSize, diskCapacity: cacheSize, directory: cacheLocation)
        config.timeoutIntervalForRequest = 30

        return URLSession(configuration: config)
    }()

    static let decoder: JSONDecoder = JSONDecoder()
    static let base = URL(string: "https://www.vogelwarte.ch/")!

    static var homepage: URL {
        let path: String
        switch primaryLanguage {
            case "de":
                path = "de/entdecken/voegel-der-schweiz/"
            case "fr":
                path = "fr/decouvrir/les-oiseaux-de-suisse/"
            case "it":
                path = "it/scoprire/uccelli-della-svizzera/"
            default:
                path = "en/discover/birds-of-switzerland/"
        }

        return VdsAPI.base.appendingPathComponent(path)
    }

    // https://www.vogelwarte.ch/wp-content/assets/json/bird/list_de.json
    // https://www.vogelwarte.ch/wp-content/assets/json/bird/filters_de.json
    // https://www.vogelwarte.ch/wp-content/assets/json/bird/labels_de.json
    // https://www.vogelwarte.ch/wp-content/assets/json/bird/species/1140_de.json
    // https://www.vogelwarte.ch/wp-content/assets/json/bird/bird_of_the_day.json
    static let jsonDataPath = "wp-content/assets/json/bird"

    // https://www.vogelwarte.ch/wp-content/assets/images/bird/headshots/80x80/1140@2x.jpg
    // https://www.vogelwarte.ch/wp-content/assets/images/bird/artbilder/700px/1140_0.jpg
    static let imageAssetPath = "wp-content/assets/images/bird"

    // https://www.vogelwarte.ch/wp-content/assets/media/voices/1140.mp3
    static let voiceAssetPath = "wp-content/assets/media/voices"

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

    private static func downloadData(_ request: URLRequest, to targetURL: URL) -> AnyPublisher<URL, Error> {
        return urlSession
            .downloadTaskPublisher(for: request)
            .retry(1)
            .tryMap { result -> URL in
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

                try? FileManager.default.removeItem(at: targetURL)
                try FileManager.default.moveItem(at: result.url, to: targetURL)
                return targetURL
            }
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
        var request = URLRequest(url: base.appendingPathComponent("\(jsonDataPath)/bird_of_the_day.json"))
        request.cachePolicy = .reloadRevalidatingCacheData
        return fetchJSON(request)
            .tryMap { (bod: [VdsBirdOfTheDay]) -> BirdOfTheDayData in
                if let first = bod.first, let id = Int(first.artID) {
                    let url = base.appendingPathComponent("wp-content/assets/images/bird/species/\(id)_0_9to4.jpg")
                    return (url, id)
                }
                throw APIError.invalidResponse
            }
            .eraseToAnyPublisher()
    }

    static func getBirdOfTheDay(for id: Int, from url: URL) -> AnyPublisher<URL, Error> {
        let speciesID = String(format: "%04d", id)
        let targetURL = cacheLocation.appendingPathComponent("bod_\(speciesID).jpg", isDirectory: false)
        if FileManager.default.fileExists(atPath: targetURL.path) {
            return Just(targetURL).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        return downloadData(URLRequest(url: url), to: targetURL)
    }
}
