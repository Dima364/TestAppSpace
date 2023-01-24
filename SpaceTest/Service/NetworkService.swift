//
//  NetworkService.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 20.12.2022.
//

import Foundation

protocol NetworkServiceProtocol {
  func getLaunches(forRocket rocket: String, completion: @escaping (Result<RocketLaunch, Error>) -> Void)
  func getRockets(completion: @escaping (Result<[Rocket], Error>) -> Void)
}

final class NetworkService: NetworkServiceProtocol {

  private enum ApiUrls {
    static let launches = "https://api.spacexdata.com/v4/launches/query"
    static let rockets = "https://api.spacexdata.com/v4/rockets"
  }

  private struct LaunchPostStruct: Encodable {
    let query: Query

    struct Query: Encodable {
      let rocket: String
      let upcoming: Bool
    }
  }

  private let session = URLSession.shared
  private let rocketDecoder = JSONDecoder()
  private let launchesDecoder = JSONDecoder()
  private let rocketDateFormatter = DateFormatter()
  private let encoder = JSONEncoder()

  init() {
    rocketDecoder.keyDecodingStrategy = .convertFromSnakeCase
    rocketDateFormatter.dateFormat = "yyyy-MM-dd"
    rocketDecoder.dateDecodingStrategy = .formatted(rocketDateFormatter)

    launchesDecoder.keyDecodingStrategy = .convertFromSnakeCase
    launchesDecoder.dateDecodingStrategy = .iso8601
  }

  func getRockets(completion: @escaping (Result<[Rocket], Error>) -> Void) {
    guard let url = URL(string: ApiUrls.rockets) else {
      completion(.failure(NetworkError.badURL))
      return
    }

    load(urlRequest: URLRequest(url: url), decoder: rocketDecoder, completion: completion)
  }

  func getLaunches(forRocket rocket: String, completion: @escaping (Result<RocketLaunch, Error>) -> Void) {
    guard let url = URL(string: ApiUrls.launches) else {
      completion(.failure(NetworkError.badURL))
      return
    }

    var request = URLRequest(url: url)
    let postStruct = LaunchPostStruct(query: LaunchPostStruct.Query(rocket: rocket, upcoming: false))
    request.setValue("Application/json", forHTTPHeaderField: "Content-Type")

    do {
      let jsonData = try encoder.encode(postStruct)
      request.httpBody = jsonData
    } catch {
      completion(.failure(NetworkError.failedToEncode))
    }

    request.httpMethod = "POST"

    load(urlRequest: request, decoder: launchesDecoder, completion: completion)
  }

  private func load<Responce: Decodable>(
    urlRequest: URLRequest,
    decoder: JSONDecoder,
    completion: @escaping (Result<Responce, Error>) -> Void
  ) {
    let task = session.dataTask(with: urlRequest) { data, _, error in
      if let error {
        completion(.failure(error))
      }
      guard let data else {
        completion(.failure(NetworkError.dataIsEmpty))
        return
      }
      do {
        let result = try  decoder.decode(Responce.self, from: data)
        completion(.success(result))
      } catch {
        completion(.failure(NetworkError.failedToDecode))
        return
      }
    }
    task.resume()
  }
}
