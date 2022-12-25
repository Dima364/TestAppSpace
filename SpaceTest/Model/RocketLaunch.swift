//
//  RocketLaunch.swift
//  SpaceTest
//  Created by Дмитрий Помин on 20.07.2022.
//

import Foundation

struct RocketLaunch: Decodable {
  let docs: [Doc]

  // MARK: - Doc
  // swiftlint: disable:next: type_name
  struct Doc: Decodable, Hashable {
    let rocket: String
    let success: Bool
    let dateLocal: Date
    let name: String
  }
}
