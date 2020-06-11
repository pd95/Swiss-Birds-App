//
//  BirdService.swift
//  Swiss-Birds
//
//  Created by Philipp on 01.06.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation
import os.log
import Combine
import UIKit

struct BirdService {

    let baseUrl = URL(string: "https://www.vogelwarte.ch/")!

    let jsonDecoder: JSONDecoder = JSONDecoder()
    let urlSession: URLSession?

    enum Endpoint {
        case birdList, labelList, filterList
        case specie(id: Int)
        case specieImage(id: Int, number: Int, size: Int = 700)
        case headshotImage(id: Int, scale: Int = 2)
        case voice(id: Int)

        static let basePath = "elements/snippets/vds/static/assets/data/"
        static let imageAssetPath = "assets/images/voegel/vds/"
        static let voiceAssetPath = "assets/media/voices/"

        var path: String {
            switch self {
                case .specie(_):
                    return Endpoint.basePath + "species/"
                case .specieImage(_ , _, let size):
                    return Endpoint.imageAssetPath + "artbilder/\(size)px/"
                case .headshotImage(_, _):
                    return Endpoint.imageAssetPath + "headshots/80x80/"
                case .voice(_):
                    return Endpoint.voiceAssetPath
                default:
                    return Endpoint.basePath
            }
        }

        func resourceName(for language: String = "de") -> String {
            switch self {
                case .birdList:
                    return "\(language)/vds-list.json"
                case .labelList:
                    return "\(language)/vds-labels.json"
                case .filterList:
                    return "\(language)/vds-filternames.json"
                case .specie(let id):
                    return "\(language)/\(id).json"
                case .specieImage(let id, let number, _):
                    return "assets/\(id)_\(number).jpg"
                case .headshotImage(let id, _):
                    return "assets/\(id)"
                case .voice(let id):
                    return "assets/\(id).mp3"
            }
        }

        func fileName(for language: String = "de") -> String {
            switch self {
                case .birdList:
                    return "vds-list-\(language).json"
                case .labelList:
                    return "vds-labels-\(language).json"
                case .filterList:
                    return "vds-filternames-\(language).json"
                case .specie(let id):
                    return "\(id)-\(language).json"
                case .specieImage(let id, let number, _):
                    return "\(String(format: "%04d", id))_\(number).jpg"
                case .headshotImage(let id, let scale):
                    return "\(id)@\(scale)x.jpg"
                case .voice(let id):
                    return "\(id).mp3"
            }
        }

        func urlPath(for language: String = "de") -> String {
            self.path+self.fileName(for: language)
        }
    }

    enum APIError: Error {
        case networkError(String)
        case httpError(Int, String)
        case resourceLoadError(String)
        case decodingError(String)
    }

    init(urlSession: URLSession) {
        self.urlSession = urlSession

        // Make sure cache directory is created
        try? FileManager.default.createDirectory(at: self.cacheLocation, withIntermediateDirectories: true, attributes: nil)
    }

    var cacheLocation: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("Downloaded-Data")
    }

    private func loadDataFromCache(for endPoint: Endpoint) throws -> Data {
        let filename = endPoint.fileName(for: language)
        let url = cacheLocation.appendingPathComponent(filename)
        let data = try Data(contentsOf: url)
        return data
    }

    private func storeDataInCache(for endPoint: Endpoint, data: Data) {
        let filename = endPoint.fileName(for: language)
        let url = cacheLocation.appendingPathComponent(filename)
        DispatchQueue.global(qos: .background).async {
            do {
                try data.write(to: url)
            } catch {
                os_log("Store to cache failed: %{Public}@\npath %{Public}@", error.localizedDescription, url.path)
            }
        }
    }

    // MARK: Helper

    func publisher(for endpoint: Endpoint) -> AnyPublisher<Data, APIError> {

        do {
            // try to fetch data from cache
            let data = try loadDataFromCache(for: endpoint)
            return Just(data)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        } catch {
            // on error: fetch from the network
            let url = baseUrl.appendingPathComponent(endpoint.urlPath(for: language))

            let urlSession = self.urlSession ?? .shared
            return urlSession.dataTaskPublisher(for: url)
                .tryMap {
                    guard let httpResponse = $0.response as? HTTPURLResponse else {
                        throw APIError.networkError("Invalid HTTP response")
                    }

                    let statusCode = httpResponse.statusCode
                    guard 200 ..< 300 ~= statusCode else {
                        let localizedMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                        os_log("Unexpected HTTP response code: %d %{Public}@", statusCode, localizedMessage)
                        throw APIError.httpError(statusCode, "HTTP \(statusCode): \(localizedMessage)")
                    }
                    self.storeDataInCache(for: endpoint, data: $0.data)
                    return $0.data
                }
                .mapError({ (failure) -> APIError in
                    os_log("Failure: %{Public}@", failure.localizedDescription)
                    return APIError.networkError(failure.localizedDescription)
                })
                .eraseToAnyPublisher()
        }
    }

    func publisher<T>(for endPoint: Endpoint) -> AnyPublisher<T, APIError> where T:Decodable {
        publisher(for: endPoint)
            .decode(type: T.self, decoder: jsonDecoder)
            .mapError { APIError.decodingError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }

    func publisher(for endPoint: Endpoint) -> AnyPublisher<UIImage?, APIError> {
        // Some images may be found in an asset catalogue
        if let image = UIImage(named: endPoint.resourceName(for: language)) {
            return Just(image)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }

        return publisher(for: endPoint)
            .map { (data: Data) -> UIImage? in
                UIImage(data: data)
            }
            .eraseToAnyPublisher()
    }


    // MARK: - Main API

    func getBirds() -> AnyPublisher<[VdsListElement], APIError> {
        return publisher(for: .birdList)
    }

    func getFilters() -> AnyPublisher<[VdsFilter], APIError> {
        publisher(for: .filterList)
    }

    func getLabels() -> AnyPublisher<[VdsLabel], APIError> {
        publisher(for: .labelList)
    }

    func getSpecie(for id: Int) -> AnyPublisher<VdsSpecieDetail, APIError> {
        publisher(for: .specie(id: id))
            .map { (array: [VdsSpecieDetail]) in array.first! }
            .eraseToAnyPublisher()
    }

    func getSpecieImage(for id: Int, number: Int, size: Int = 700) -> AnyPublisher<UIImage?, APIError> {
        publisher(for: .specieImage(id: id, number: number, size: size))
    }

    func getSpecieHeadshot(for id: Int, scale: Int = 2) -> AnyPublisher<UIImage?, APIError> {
        publisher(for: .headshotImage(id: id, scale: scale))
    }

    func getVoice(for id: Int) -> AnyPublisher<Data, APIError> {
        publisher(for: .voice(id: id))
    }
}
