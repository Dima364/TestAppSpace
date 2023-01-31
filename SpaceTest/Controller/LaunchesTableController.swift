//
//  LaunchesTableController.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 14.11.2022.
//

import UIKit

final class LaunchesTableController: UITableViewController {
  private var items: [LaunchItem] = []

  // swiftlint: disable:next: implicitly_unwrapped_optional
  var presenter: LaunchesPresenterProtocol!

  override func viewDidLoad() {
    super.viewDidLoad()
    title = presenter.rocketName
    presenter.getLaunches()
  }

  // MARK: - UITableViewDelegate
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    100
  }

  // MARK: - UITableViewDataSource
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = self.tableView.dequeueReusableCell(
      withIdentifier: "LaunchesTableCell",
      for: indexPath
    ) as? LaunchesTableCell else {
      return UITableViewCell()
    }

    let launch = items[indexPath.row]

    cell.configure(
      name: launch.title,
      date: launch.date,
      imageName: launch.image
    )

    return cell
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    items.count
  }
}

// MARK: - LaunchesTableControllerProtocol
extension LaunchesTableController: LaunchesTableControllerProtocol {
  func success(with launches: [LaunchItem]) {
    self.items = launches
    tableView.reloadData()
  }

  func failure(with error: Error) {
    presentAlert(withMessage: error.localizedDescription)
  }
}
