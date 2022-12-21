//
//  ErrorHandling.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 17.11.2022.
//

import Foundation

enum NetworkError: Error {
  case badURL
  case failedToDecode
  case failedToEncode
  case dataIsEmpty
}

enum ErrorStrings: Error {
  case unknownError
}

enum SectionError: Error {
  case sectionError
}
enum UserDefaultsError: Error {
  case wrongKey
}
