//
//  StringExtension.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 20.12.2022.
//

import Foundation

extension Date {
  static let dateFormatterRu = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ru_RU")
    dateFormatter.dateFormat = "d MMMM, yyyy"
    return dateFormatter
  }()
}
