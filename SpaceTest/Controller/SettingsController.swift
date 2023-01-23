//
//  SettingsController.swift
//  SpaceTest
//  Created by Дмитрий Помин on 13.07.2022.
//

import UIKit

final class SettingsController: UIViewController {
  private var items: [SettingsItem] = []
  var presenter: SettingsPresenterProtocol!
  var settingsUpdate: (() -> Void)?

  @IBOutlet private var tableView: UITableView!

  @IBAction
  private func exitButton(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    self.presenter.getSettingsItems()
  }
}

// MARK: - UITableViewDataSource
extension SettingsController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let item = items[indexPath.row]

    guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as? SettingsCell
    else {
      return UITableViewCell()
    }

    cell.configure(hint: item.title, selectedIndex: item.index, metrics: item.metrics)

    cell.onChangeSetting = { [weak self] index in
      self?.presenter.saveChanges(dimension: item.title, metric: item.metrics[index])
      self?.settingsUpdate?()
    }
    return cell
  }
}

// MARK: - SettingsControllerProtocol
extension SettingsController: SettingsControllerProtocol {
  func present(with items: [SettingsItem]) {
    self.items = items
    tableView.reloadData()
  }
}
