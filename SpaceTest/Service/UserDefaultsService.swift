//
//  UserDefaultsWorker.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 19.11.2022.
//

import Foundation

final class UserDefaultsService {
  typealias Hints = RocketSectionCreator.Hints
  typealias MetricSymbols = RocketSectionCreator.MetricSymbols

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

  func getMetricType(forDimension dimension: Hints) -> MetricSymbols? {
    guard let userDefaultsValue = userDefaults.string(forKey: dimension.rawValue),
    let metricSymbol = MetricSymbols(rawValue: userDefaultsValue) else {
      return nil
    }
    return metricSymbol
  }

  func setMetricType(metricType: MetricSymbols, forDimension dimension: Hints) {
    userDefaults.set(metricType.rawValue, forKey: dimension.rawValue)
  }
}
