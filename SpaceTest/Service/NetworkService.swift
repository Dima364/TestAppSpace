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

  private let jsonDecoder = JSONDecoder()
  private let session = URLSession.shared
  private let dateFormatter = DateFormatter()

  init() {
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
  }

  func getRockets(completion: @escaping (Result<[Rocket], Error>) -> Void) {
    dateFormatter.dateFormat = DateFormatType.rocketResponce.description
    jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)

    guard let url = URL(string: ApiUrls.rockets) else {
      completion(.failure(NetworkError.badURL))
      return
    }

    load(url: URLRequest(url: url), completion: completion)
  }

  func getLaunches(forRocket rocket: String, completion: @escaping (Result<RocketLaunch, Error>) -> Void) {
    dateFormatter.dateFormat = DateFormatType.launchesResponce.description
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

    load(url: request, completion: completion)
  }

  private func load<T: Decodable>(url: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
    let task = session.dataTask(with: url) { data, _, error in
      guard let data = data, error == nil else {
        completion(.failure(error!))
        return
      }
      do {
        let result = try  self.jsonDecoder.decode(T.self, from: data)
        DispatchQueue.main.async {
          completion(.success(result))
        }
      } catch {
        completion(.failure(NetworkError.failedToDecode))
        return
      }
    }
    task.resume()
  }
}
