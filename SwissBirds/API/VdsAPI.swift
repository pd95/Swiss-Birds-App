//
//  VdsAPI.swift
//  SwissBirds
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

    static let logger = Logger(subsystem: "VdsAPI", category: "general")

    static var cacheLocation: URL = {
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("Downloaded-Data")
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        } catch {
            fatalError("Unable to create temporary directory \(url.path): \(error)")
        }
        return url
    }()

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
    // https://www.vogelwarte.ch/wp-content/assets/images/bird/species/1140_1.jpg
    static let imageAssetPath = "wp-content/assets/images/bird"

    // https://www.vogelwarte.ch/wp-content/assets/media/voices/1140.mp3
    static let voiceAssetPath = "wp-content/assets/media/voices"

    private static func fetchData(_ request: URLRequest) -> AnyPublisher<Data, Error> {
        logger.info("\(#function): \(request.url!.absoluteString)")
        return urlSession
            .dataTaskPublisher(for: request)
            .retry(1)
            .tryMap { [logger] result -> Data in
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    logger.error("Invalid HTTP response: \(result.response.description, privacy: .public)")
                    throw APIError.networkError("Invalid HTTP response")
                }

                let statusCode = httpResponse.statusCode
                guard 200 ..< 300 ~= statusCode else {
                    let localizedMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                    logger.error("HTTP response: \(statusCode) '\(localizedMessage)' for \(httpResponse.url?.path ?? "n/a", privacy: .public)")
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
                    logger.error("Error: \(error.localizedDescription, privacy: .public)  for \(request.url?.path ?? "n/a", privacy: .public)")
                    logger.error("\(error as NSError, privacy: .public)")
                }
            })
            .eraseToAnyPublisher()
    }

    private static func downloadData(_ request: URLRequest, to targetURL: URL) -> AnyPublisher<URL, Error> {
        return urlSession
            .downloadTaskPublisher(for: request)
            .retry(1)
            .tryMap { [logger] result -> URL in
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    logger.error("Invalid HTTP response: \(result.response.description, privacy: .public)")
                    throw APIError.networkError("Invalid HTTP response")
                }

                let statusCode = httpResponse.statusCode
                guard 200 ..< 300 ~= statusCode else {
                    let localizedMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                    logger.error("HTTP response: \(statusCode) '\(localizedMessage)' for \(httpResponse.url?.path ?? "n/a", privacy: .public)")
                    throw APIError.httpError(statusCode, "HTTP \(statusCode): \(localizedMessage)")
                }

                do {
                    try? FileManager.default.removeItem(at: targetURL)
                    try FileManager.default.moveItem(at: result.url, to: targetURL)
                } catch {
                    logger.error("Unable to move item: \(error, privacy: .public)")
                    throw error
                }
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

    static func getSpecieImage(for id: Int, number: Int) -> AnyPublisher<Data, Error> {
        return fetchData(URLRequest(url: base.appendingPathComponent("\(imageAssetPath)/species/\(id)_\(number).jpg")))
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
                // https://www.vogelwarte.ch/wp-content/assets/images/bird/species/0750_0_9to4.jpg
                // https://www.vogelwarte.ch/wp-content/assets/images/bird/species/3500_0_9to4.jpg
                let matches = html.matches(regex: "wp-content/assets/images/bird/species/([0-9]+)_0_\\dto\\d.jpg")
                let matchCount = matches.count
                logger.debug("getBirdOfTheDaySpeciesIDandURL: \(matches.count) regex matches found -> \(matches.debugDescription)")
                if matchCount >= 2, let id = Int(matches[matchCount-1]) {
                    let url = base.appendingPathComponent("wp-content/assets/images/bird/species/\(id)_0_9to4.jpg")
                    logger.debug("getBirdOfTheDaySpeciesIDandURL: Returning id \(id) and \(url)")
                    return (url, id)
                }
                logger.error("getBirdOfTheDaySpeciesIDandURL: Unable to extract bird ID and URL: \(matches.count) regex matches found -> \(matches.debugDescription)")
                throw APIError.invalidResponse
            }
            .eraseToAnyPublisher()
    }

    static func getBirdOfTheDay(for id: Int, from url: URL) -> AnyPublisher<URL, Error> {
        let speciesID = String(format: "%04d", id)
        let targetURL = cacheLocation.appendingPathComponent("bod_\(speciesID).jpg", isDirectory: false)
        if FileManager.default.fileExists(atPath: targetURL.path) {
            logger.debug("getBirdOfTheDay: returning existing file from \(targetURL)")
            return Just(targetURL).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        let url = base.appendingPathComponent("wp-content/assets/images/bird/species/\(speciesID)_0_9to4.jpg")
        logger.debug("getBirdOfTheDay: loading from \(url)")
        return downloadData(URLRequest(url: url), to: targetURL)
    }
}
