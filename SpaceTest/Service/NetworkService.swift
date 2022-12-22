//
//  NetworkService.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 20.12.2022.
//

import Foundation

final class NetworkService {

  enum ApiUrls {
    static let launches = "https://api.spacexdata.com/v4/launches/query"
    static let rockets = "https://api.spacexdata.com/v4/rockets"
  }

  struct LaunchPostStruct: Encodable {
    let query: Query

    struct Query: Encodable {
      let rocket: String
      let upcoming: Bool
    }
  }

  enum DateFormatType: String {
    case rocketResponce
    case launchesResponce
    var description: String {
      switch self {
      case .rocketResponce:
        return "yyyy-MM-dd"
      case .launchesResponce:
        return "yyyy-MM-dd'T'HH:mm:ssZ"
      }
    }
  }

  private let session = URLSession.shared
  private let dateFormatter = DateFormatter()

  func getRockets(completion: @escaping (Result<[Rocket], Error>) -> Void) {
    dateFormatter.dateFormat = DateFormatType.rocketResponce.description

    let jsonDecoder = JSONDecoder()
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)

    guard let url = URL(string: ApiUrls.rockets) else {
      completion(.failure(NetworkError.badURL))
      return
    }

    load(urlRequest: URLRequest(url: url), decoder: jsonDecoder, completion: completion)
  }

  func getLaunches(forRocket rocket: String, completion: @escaping (Result<RocketLaunch, Error>) -> Void) {
    dateFormatter.dateFormat = DateFormatType.launchesResponce.description

    let jsonDecoder = JSONDecoder()
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)

    guard let url = URL(string: ApiUrls.launches) else {
      completion(.failure(NetworkError.badURL))
      return
    }

    var request = URLRequest(url: url)
    let postStruct = LaunchPostStruct(query: LaunchPostStruct.Query(rocket: rocket, upcoming: false))
    request.setValue("Application/json", forHTTPHeaderField: "Content-Type")

    do {
      let jsonData = try JSONEncoder().encode(postStruct)
      request.httpBody = jsonData
    } catch {
      completion(.failure(NetworkError.failedToEncode))
    }

    request.httpMethod = "POST"

    load(urlRequest: request, decoder: jsonDecoder, completion: completion)
  }

  private func load<T: Decodable>(urlRequest: URLRequest, decoder: JSONDecoder, completion: @escaping (Result<T, Error>) -> Void) {
    let task = session.dataTask(with: urlRequest) { data, _, error in
      if let error {
        completion(.failure(error))
      }
      guard let data else {
        completion(.failure(NetworkError.dataIsEmpty))
        return
      }
      do {
        let result = try  decoder.decode(T.self, from: data)
        completion(.success(result))
      } catch {
        completion(.failure(NetworkError.failedToDecode))
        return
      }
    }
    task.resume()
  }
}
