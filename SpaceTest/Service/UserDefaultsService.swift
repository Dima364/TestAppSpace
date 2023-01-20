//
//  UserDefaultsWorker.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 19.11.2022.
//

import Foundation

protocol UserDefaultsServiceProtocol: AnyObject {
  func makeSettingsDefaults()
  func getMetricType(for dimension: Hints) -> MetricSymbols?
  func setMetricType(for dimension: Hints, with: MetricSymbols)
}

final class UserDefaultsService: UserDefaultsServiceProtocol {
  private let userDefaults = UserDefaults.standard

  func makeSettingsDefaults() {
    userDefaults.register(
      defaults: [
        String(describing: Hints.height.rawValue): MetricSymbols.feet.rawValue,
        String(describing: Hints.diameter.rawValue): MetricSymbols.meters.rawValue,
        String(describing: Hints.mass.rawValue): MetricSymbols.kilos.rawValue,
        String(describing: Hints.payloadWeight.rawValue): MetricSymbols.pounds.rawValue
      ]
    )
  }

  func getMetricType(for dimension: Hints) -> MetricSymbols? {
    guard let userDefaultsValue = userDefaults.string(forKey: dimension.rawValue),
    let metricSymbol = MetricSymbols(rawValue: userDefaultsValue) else {
      return nil
    }
    return metricSymbol
  }

  func setMetricType(for dimension: Hints, with: MetricSymbols) {
    userDefaults.set(with.rawValue, forKey: dimension.rawValue)
  }
}
