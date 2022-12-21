//
//  DoubleExtension.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 20.12.2022.
//

import Foundation

extension Double {
  func toString() -> String {
    String(format: "%.1f", self)
  }
}
