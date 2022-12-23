//
//  SettingsController.swift
//  SpaceTest
//  Created by Дмитрий Помин on 13.07.2022.
//

import UIKit

final class SettingsController: UIViewController {
  private typealias Hints = RocketSectionCreator.Hints
  private typealias MetricSymbols = RocketSectionCreator.MetricSymbols

  private let userDefaultsService: UserDefaultsService
  private let settingsItemsType = [Hints.height, Hints.diameter, Hints.mass, Hints.payloadWeight]

  var settingsUpdate: (() -> Void)?

  @IBOutlet private var tableView: UITableView!

  @IBAction
  private func exitButton(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }

  required init?(coder: NSCoder) {
    userDefaultsService = UserDefaultsService()
    super.init(coder: coder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
  }
}

// MARK: - UITableViewDataSource
extension SettingsController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    settingsItemsType.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let metrics: [String]
    let dimension = settingsItemsType[indexPath.row]

    switch dimension {
    case .height, .diameter:
      metrics = [MetricSymbols.meters.rawValue, MetricSymbols.feet.rawValue]
    case .mass, .payloadWeight:
      metrics = [MetricSymbols.kilos.rawValue, MetricSymbols.pounds.rawValue]
    default:
      metrics = []
    }

    guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as? SettingsCell,
      let userDefaultsSymbol = userDefaultsService.getMetricType(forDimension: settingsItemsType[indexPath.row]),
      let symbol = MetricSymbols(rawValue: userDefaultsSymbol.rawValue),
      let selectedIndex = metrics.firstIndex(of: symbol.rawValue)
    else {
      return UITableViewCell()
    }

    cell.configure(hint: dimension.rawValue, selectedIndex: selectedIndex, metrics: metrics)

    cell.onChangeSetting = { index in
      guard let metricType = MetricSymbols(rawValue: metrics[index]) else { return }
      self.userDefaultsService.setMetricType(metricType: metricType, forDimension: dimension)
      self.settingsUpdate?()
    }
    return cell
  }
}
