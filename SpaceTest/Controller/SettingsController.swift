//
//  SettingsController.swift
//  SpaceTest
//  Created by Дмитрий Помин on 13.07.2022.
//

import UIKit

final class SettingsController: UIViewController {
  typealias Hints = RocketSectionCreator.Hints
  typealias MetricSymbols = RocketSectionCreator.MetricSymbols

  private let settingsCell = SettingsCell()
  private let settings = UserDefaults.standard
  private let settingsItemsType = [Hints.height, Hints.diameter, Hints.mass, Hints.payloadWeight]
  var settingsUpdate: (() -> Void)?

  @IBOutlet private var tableView: UITableView!

  @IBAction
  private func exitButton(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
  }
}

extension SettingsController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    settingsItemsType.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let hint = settingsItemsType[indexPath.row].rawValue
    var metrics: [String] = []

    switch settingsItemsType[indexPath.row] {
    case .height, .diameter:
      metrics = [MetricSymbols.meters.rawValue, MetricSymbols.feet.rawValue]
    case .mass, .payloadWeight:
      metrics = [MetricSymbols.kilos.rawValue, MetricSymbols.pounds.rawValue]
    default:
      break
    }

    guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as? SettingsCell,
      let userDefaultsSymbol = settings.string(forKey: hint),
      let symbol = MetricSymbols(rawValue: userDefaultsSymbol),
      let selectedIndex = metrics.firstIndex(of: symbol.rawValue)
    else {
      return UITableViewCell()
    }

    cell.configure(hint: hint, selectedIndex: selectedIndex, metrics: metrics)

    cell.onChangeSetting = { index in
      self.settings.set(metrics[index], forKey: hint)
      self.settingsUpdate?()
    }
    return cell
  }
}
