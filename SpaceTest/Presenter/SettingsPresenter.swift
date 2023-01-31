//
//  SettingsPresenter.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 19.01.2023.
//

import Foundation

protocol SettingsControllerProtocol: AnyObject {
  func present(with items: [SettingsItem])
}

protocol SettingsPresenterProtocol: AnyObject {
  func getSettingsItems()
  func saveChanges(dimension: String, metric: String)
  var view: SettingsControllerProtocol? { get set }
}

final class SettingsPresenter: SettingsPresenterProtocol {
  weak var view: SettingsControllerProtocol?
  private let userDefaultsService: UserDefaultsServiceProtocol
  private let dimensionTypes = [Hints.height, Hints.diameter, Hints.mass, Hints.payloadWeight]

  init(view: SettingsControllerProtocol?, userDefaultsService: UserDefaultsServiceProtocol) {
    self.userDefaultsService = userDefaultsService
  }

  private func getMetrics(for hint: Hints) -> [String] {
    let metrics: [String]
    switch hint {
    case .height, .diameter:
      metrics = [MetricSymbols.meters.rawValue, MetricSymbols.feet.rawValue]
    case .mass, .payloadWeight:
      metrics = [MetricSymbols.kilos.rawValue, MetricSymbols.pounds.rawValue]
    default:
      metrics = []
    }
    return metrics
  }

  func getSettingsItems() {
    let settingsItems: [SettingsItem] = dimensionTypes.compactMap { dimension in
      let metrics: [String] = getMetrics(for: dimension)

      guard let userDefaultsSymbol = userDefaultsService.getMetricType(for: dimension),
        let symbol = MetricSymbols(rawValue: userDefaultsSymbol.rawValue),
        let selectedIndex = metrics.firstIndex(of: symbol.rawValue)
      else { return nil }

      return SettingsItem(title: dimension.rawValue, index: selectedIndex, metrics: getMetrics(for: dimension))
    }
    view?.present(with: settingsItems)
  }

  func saveChanges(dimension: String, metric: String) {
    guard let hint = Hints(rawValue: dimension),
      let metric = MetricSymbols(rawValue: metric)
    else { return }

    self.userDefaultsService.setMetricType(for: hint, with: metric)
  }
}
